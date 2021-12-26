######################################################################
### CloudTrail

resource "aws_cloudtrail" "Org_CloudTrail" {
  count = local.IS_ROOT_ACCOUNT ? 1 : 0

  name = var.org_cloudtrail.name

  is_organization_trail         = true
  is_multi_region_trail         = true
  include_global_service_events = true # global services like IAM and STS

  # Logging Config
  s3_bucket_name = var.org_log_archive_s3_bucket.name
  # TODO As of 12/6/21, this rule always err's out. Rm the 'ignore' directive once they fix it.
  #tfsec:ignore:aws-cloudtrail-enable-at-rest-encryption
  kms_key_id                 = one(aws_kms_key.Org_KMS_Key).arn
  enable_log_file_validation = true

  # CloudTrail requires the Log Stream wildcard as shown below
  cloud_watch_logs_group_arn = "arn:aws:logs:${local.aws_region}:${var.log_archive_account_id}:log-group:${var.org_cloudtrail_cloudwatch_logs_group.log_group.name}:*"
  cloud_watch_logs_role_arn  = one(aws_iam_role.CloudWatch-Delivery_Role).arn

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }

  # TODO add CloudTrail Insights for API call rate and API error rate

  tags = var.org_cloudtrail.tags
}

#---------------------------------------------------------------------
### Org CloudTrail --> CloudWatchLogs Log Group

locals {
  # Shorten long variable refs
  cw_log_grp  = var.org_cloudtrail_cloudwatch_logs_group.log_group
  cw_svc_role = var.org_cloudtrail_cloudwatch_logs_group.iam_service_role
}

# This CW log group accepts the Org's CloudTrail event stream

resource "aws_cloudwatch_log_group" "CloudTrail_Events" {
  count = local.IS_LOG_ARCHIVE_ACCOUNT ? 1 : 0

  name              = local.cw_log_grp.name
  retention_in_days = coalesce(local.cw_log_grp.retention_in_days, 365)
  tags              = local.cw_log_grp.tags
}

#---------------------------------------------------------------------
# IAM Service Role to deliver CloudTrail Events to the CloudWatch Log Group:

resource "aws_iam_role" "CloudWatch-Delivery_Role" {
  count = local.IS_ROOT_ACCOUNT ? 1 : 0

  name = local.cw_svc_role.name
  tags = local.cw_svc_role.tags
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "CloudWatchDeliveryAssumeRolePolicy"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

#---------------------------------------------------------------------
# The IAM policy allowing the service role to deliver CloudTrail events to the CW log group:

/* CloudWatch Resource ARN Formats:
Log group     arn:aws:logs:REGION:ACCOUNT_ID:log-group:LOG_GRP_NAME
Log stream    arn:aws:logs:REGION:ACCOUNT_ID:log-group:LOG_GRP_NAME:log-stream:LOG_STREAM_NAME
Destination   arn:aws:logs:REGION:ACCOUNT_ID:destination:DEST_NAME
*/

locals {
  cw_log_grp_arn = "aws:aws:logs:${local.aws_region}:${var.log_archive_account_id}:log-group:${local.cw_log_grp.name}"
}

resource "aws_iam_policy" "CloudWatch-Delivery_Role_Policy" {
  count = local.IS_ROOT_ACCOUNT ? 1 : 0

  name        = coalesce(local.cw_svc_role.policy.name, "${local.cw_svc_role.name}_Policy")
  description = local.cw_svc_role.policy.description
  path        = coalesce(local.cw_svc_role.policy.path, "/")
  tags        = local.cw_svc_role.policy.tags
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudTrailCreateLogStreamAndPutLogEvents"
        Effect = "Allow"
        Action = ["logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = [
          "${local.cw_log_grp_arn}:log-stream:*_CloudTrail_*",
          "${local.cw_log_grp_arn}:log-stream:${local.org_id}_*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "CloudWatch-Delivery_Role_Policy" {
  count = local.IS_ROOT_ACCOUNT ? 1 : 0

  role       = one(aws_iam_role.CloudWatch-Delivery_Role).name
  policy_arn = one(aws_iam_policy.CloudWatch-Delivery_Role_Policy).arn
}

######################################################################
