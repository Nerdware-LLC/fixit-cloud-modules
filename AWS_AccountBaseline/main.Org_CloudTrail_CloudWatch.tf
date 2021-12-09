######################################################################
### Org CloudTrail --> CloudWatchLogs Log Group

locals {
  # Flatten some references to nested var properties -
  cw_log_grp         = var.cloudtrail-to-cloudwatch-config.cloudwatch_log_group
  cw_svc_role        = var.cloudtrail-to-cloudwatch-config.iam_service_role
  cw_svc_role_policy = var.cloudtrail-to-cloudwatch-config.iam_role_policy
}

# This CW log group accepts the Org's CloudTrail event stream

resource "aws_cloudwatch_log_group" "CloudTrail_Events" {
  count = local.IS_ROOT_ACCOUNT ? 1 : 0

  name              = local.cw_log_grp.name
  kms_key_id        = one(aws_kms_key.Org_CloudTrail_KMS_Key).arn
  retention_in_days = coalesce(local.cw_log_grp.retention_in_days, 365)
  tags              = local.cw_log_grp.tags
}

# IAM Service Role to deliver CloudTrail Events to the CloudWatch Log Group:

resource "aws_iam_role" "CloudWatch-Delivery_Role" {
  count = local.IS_ROOT_ACCOUNT ? 1 : 0

  name               = local.cw_svc_role.name
  assume_role_policy = data.aws_iam_policy_document.CloudWatch-Delivery_AssumeRole_Policy.json
  tags               = local.cw_svc_role.tags
}

data "aws_iam_policy_document" "CloudWatch-Delivery_AssumeRole_Policy" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# The IAM policy allowing the service role to deliver CloudTrail events to the CW log group:

resource "aws_iam_role_policy" "CloudTrail-CloudWatch-Delivery_Policy" {
  count = local.IS_ROOT_ACCOUNT ? 1 : 0

  name   = local.cw_svc_role_policy.name
  role   = one(aws_iam_role.CloudWatch-Delivery_Role).id
  policy = data.aws_iam_policy_document.CloudTrail-CloudWatch-Delivery_Policy.json
}

locals {
  # These locals simply help to shorten long lines in the below policy doc
  log_stream_COMMON_PREFIX = (
    "arn:aws:logs:${local.aws_region}:${local.root_account_id}:log-group:${local.cw_log_grp.name}:log-stream"
  )

  log_grp_stream_arns = [
    "${local.log_stream_COMMON_PREFIX}:${local.root_account_id}_CloudTrail_${local.aws_region}*",
    "${local.log_stream_COMMON_PREFIX}:${data.aws_organizations_organization.this.id}_*",
  ]
}

# Used by the CloudTrail-CloudWatch-Delivery_Policy IAM Service Role
data "aws_iam_policy_document" "CloudTrail-CloudWatch-Delivery_Policy" {
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

######################################################################
