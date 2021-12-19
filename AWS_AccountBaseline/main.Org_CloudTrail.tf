######################################################################
### CloudTrail

resource "aws_cloudtrail" "Org_CloudTrail" {
  count = local.IS_ROOT_ACCOUNT ? 1 : 0

  name = var.org_cloudtrail.name

  is_organization_trail         = true
  include_global_service_events = true # global services like IAM and STS
  is_multi_region_trail         = true

  # Logging Config
  s3_bucket_name = var.org_log_archive_s3_bucket.name
  # TODO As of 12/6/21, this rule always err's out. Rm the 'ignore' directive once they fix it.
  #tfsec:ignore:aws-cloudtrail-enable-at-rest-encryption
  kms_key_id                 = one(aws_kms_key.Org_KMS_Key).arn
  enable_log_file_validation = true

  # CloudTrail requires the Log Stream wildcard as shown below
  cloud_watch_logs_group_arn = "${one(aws_cloudwatch_log_group.CloudTrail_Events).arn}:*"
  cloud_watch_logs_role_arn  = one(aws_iam_role.CloudWatch-Delivery_Role).arn

  # TODO maybe turn the below item on
  # sns_topic_name = aws_sns_topic.cloudtrail-sns-topic[0].arn

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }

  insight_selector {
    insight_type = "ApiCallRateInsight"
  }

  tags = var.org_cloudtrail.tags
}

#---------------------------------------------------------------------
### Org CloudTrail --> CloudWatchLogs Log Group

locals {
  # Flatten some references to nested var properties -
  cw_log_grp  = var.org_cloudtrail.cloudwatch_config.log_group
  cw_svc_role = var.org_cloudtrail.cloudwatch_config.iam_service_role
}

#---------------------------------------------------------------------
# This CW log group accepts the Org's CloudTrail event stream

resource "aws_cloudwatch_log_group" "CloudTrail_Events" {
  count = local.IS_LOG_ARCHIVE_ACCOUNT ? 1 : 0

  name              = local.cw_log_grp.name
  kms_key_id        = one(aws_kms_key.Org_KMS_Key).arn
  retention_in_days = coalesce(local.cw_log_grp.retention_in_days, 365)
  tags              = local.cw_log_grp.tags
}

#---------------------------------------------------------------------
# IAM Service Role to deliver CloudTrail Events to the CloudWatch Log Group:

resource "aws_iam_role" "CloudWatch-Delivery_Role" {
  count = local.IS_LOG_ARCHIVE_ACCOUNT ? 1 : 0

  name               = local.cw_svc_role.name
  assume_role_policy = one(data.aws_iam_policy_document.CloudWatch-Delivery_AssumeRole_Policy).json
  tags               = local.cw_svc_role.tags
}

data "aws_iam_policy_document" "CloudWatch-Delivery_AssumeRole_Policy" {
  count = local.IS_LOG_ARCHIVE_ACCOUNT ? 1 : 0

  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

#---------------------------------------------------------------------
# The IAM policy allowing the service role to deliver CloudTrail events to the CW log group:

resource "aws_iam_role_policy" "CloudWatch-Delivery_Role_Policy" {
  count = local.IS_LOG_ARCHIVE_ACCOUNT ? 1 : 0

  name   = coalesce(local.cw_svc_role.policy_name, "${local.cw_svc_role.name}-Policy")
  role   = one(aws_iam_role.CloudWatch-Delivery_Role).id
  policy = one(data.aws_iam_policy_document.CloudWatch-Delivery_Role_Policy).json
}

# Used by the CloudTrail-CloudWatch-Delivery_Policy IAM Service Role
data "aws_iam_policy_document" "CloudWatch-Delivery_Role_Policy" {
  count = local.IS_LOG_ARCHIVE_ACCOUNT ? 1 : 0

  statement {
    sid       = "AWSCloudTrailCreateLogStream"
    actions   = ["logs:CreateLogStream"]
    resources = local.log_grp_stream_arns
  }

  statement {
    sid       = "AWSCloudTrailPutLogEvents"
    actions   = ["logs:PutLogEvents"]
    resources = local.log_grp_stream_arns
  }
}

locals {
  # These locals simply help to shorten long lines in the below policy doc
  log_stream_COMMON_PREFIX = (
    "arn:aws:logs:${local.aws_region}:${var.log_archive_account_id}:log-group:${local.cw_log_grp.name}:log-stream"
  )

  log_grp_stream_arns = [
    "${local.log_stream_COMMON_PREFIX}:${var.log_archive_account_id}_CloudTrail_${local.aws_region}*",
    "${local.log_stream_COMMON_PREFIX}:${data.aws_organizations_organization.this.id}_*",
  ]
}

######################################################################
