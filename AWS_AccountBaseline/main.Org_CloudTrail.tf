######################################################################
### CloudTrail

/* When you create an organization trail, each member account receives
two related resources:
    1) A trail of the same name.
    2) A service-linked role called "AWSServiceRoleForCloudTrail"
       that performs logging tasks.
*/

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
  cloud_watch_logs_group_arn = "${one(data.aws_cloudwatch_log_group.CloudTrail_Events).arn}:*"
  cloud_watch_logs_role_arn  = one(data.aws_iam_role.CloudWatch-Delivery_Role).arn

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }

  # TODO add CloudTrail Insights for API call rate and API error rate

  tags = var.org_cloudtrail.tags
}

/* These data blocks ensure "root" doesn't have to explicitly provide
the Log-Archive-owned CW Log Grp and its Role as input variables.  */

data "aws_cloudwatch_log_group" "CloudTrail_Events" {
  count = local.IS_ROOT_ACCOUNT ? 1 : 0

  name = local.cw_log_grp.name
}

data "aws_iam_role" "CloudWatch-Delivery_Role" {
  count = local.IS_ROOT_ACCOUNT ? 1 : 0

  name = local.cw_svc_role.name
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
  retention_in_days = coalesce(local.cw_log_grp.retention_in_days, 365)
  tags              = local.cw_log_grp.tags
}

#---------------------------------------------------------------------
# IAM Service Role to deliver CloudTrail Events to the CloudWatch Log Group:

resource "aws_iam_role" "CloudWatch-Delivery_Role" {
  count = local.IS_LOG_ARCHIVE_ACCOUNT ? 1 : 0

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

resource "aws_iam_role_policy" "CloudWatch-Delivery_Role_Policy" {
  count = local.IS_LOG_ARCHIVE_ACCOUNT ? 1 : 0

  name = coalesce(local.cw_svc_role.policy_name, "${local.cw_svc_role.name}_Policy")
  role = one(aws_iam_role.CloudWatch-Delivery_Role).id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudTrailCreateLogStreamAndPutLogEvents"
        Action = ["logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = [
          "${one(aws_cloudwatch_log_group.CloudTrail_Events).arn}:log-stream:*_CloudTrail_*",
          "${one(aws_cloudwatch_log_group.CloudTrail_Events).arn}:log-stream:${local.org_id}_*",
        ]
      }
    ]
  })
}

######################################################################
