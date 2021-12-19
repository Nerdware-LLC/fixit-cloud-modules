######################################################################
### AWS Config

/* NOTE: If we see duplicated Config findings for global resources, we'll
need to restrict Config to only post findings in the main/home region.  */

resource "aws_config_configuration_recorder" "Org_Config_Recorder" {
  count = local.IS_ROOT_ACCOUNT ? 1 : 0

  name     = var.org_aws_config.recorder_name
  role_arn = one(aws_iam_role.Org_Config_Role).arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_config_configuration_recorder_status" "Org_Config_Recorder_Status" {
  count = local.IS_ROOT_ACCOUNT ? 1 : 0

  name       = one(aws_config_configuration_recorder.Org_Config_Recorder).id
  is_enabled = true

  depends_on = [aws_config_delivery_channel.Org_Config_Delivery_Channel]
}

#---------------------------------------------------------------------
### AWS Config - Organization Aggregator

resource "aws_config_configuration_aggregator" "Org_Config_Aggregator" {
  count = local.IS_ROOT_ACCOUNT ? 1 : 0

  name = var.org_aws_config.aggregator.name
  tags = var.org_aws_config.aggregator.tags

  organization_aggregation_source {
    all_regions = true
    role_arn    = one(aws_iam_role.Org_Config_Role).arn
  }

  depends_on = [aws_iam_role_policy_attachment.AWS-Managed-Config-Svc-Role-Policy]
}

#---------------------------------------------------------------------
### AWS Config - IAM Service Role

/* This role is used to make read or write requests to the delivery
channel and to describe the AWS resources associated with the account */
resource "aws_iam_role" "Org_Config_Role" {
  count = local.IS_ROOT_ACCOUNT ? 1 : 0

  name = var.org_aws_config.service_role.name
  tags = var.org_aws_config.service_role.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowConfigServiceAssumeRole"
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "config.amazonaws.com" }
      }
    ]
  })
}

# Attach AWS-managed service role policy for AWS Config
resource "aws_iam_role_policy_attachment" "AWS-Managed-Config-Svc-Role-Policy" {
  count = local.IS_ROOT_ACCOUNT ? 1 : 0

  role       = one(aws_iam_role.Org_Config_Role).name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRoleForOrganizations"
}

/* This data source ensures the "root" account doesn't need to explicitly provide
the ARN of the Org_Log_Archive_S3 bucket owned by the "Log-Archive" account.  */
data "aws_s3_bucket" "Org_Log_Archive_S3" {
  count = local.IS_ROOT_ACCOUNT ? 1 : 0

  bucket = var.org_log_archive_s3_bucket.name
}

resource "aws_iam_role_policy" "Org_Config_Role_Policy" {
  count = local.IS_ROOT_ACCOUNT ? 1 : 0

  name = var.org_aws_config.service_role.policy_name
  role = one(aws_iam_role.Org_Config_Role).id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["s3:*"]
        Effect = "Allow"
        Resource = [
          "${one(data.aws_s3_bucket.Org_Log_Archive_S3).arn}",
          "${one(data.aws_s3_bucket.Org_Log_Archive_S3).arn}/*"
        ]
      }
    ]
  })
}

#---------------------------------------------------------------------
### AWS Config - SNS Topic

resource "aws_sns_topic" "Org_Config_SNS_Topic" {
  count = local.IS_ROOT_ACCOUNT ? 1 : 0

  name              = var.org_aws_config.sns_topic.name
  display_name      = var.org_aws_config.sns_topic.display_name
  kms_master_key_id = one(aws_kms_key.Org_KMS_Key).id
  tags              = var.org_aws_config.sns_topic.tags
}

resource "aws_sns_topic_policy" "Org_Config_SNS_Topic_Policy" {
  count = local.IS_ROOT_ACCOUNT ? 1 : 0

  arn    = one(aws_sns_topic.Org_Config_SNS_Topic).arn
  policy = one(data.aws_iam_policy_document.Org_Config_SNS_Topic_Policy_Document).json
}

data "aws_iam_policy_document" "Org_Config_SNS_Topic_Policy_Document" {
  count = local.IS_ROOT_ACCOUNT ? 1 : 0

  statement {
    actions   = ["sns:Publish"]
    resources = [one(aws_sns_topic.Org_Config_SNS_Topic).arn]

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    # TODO add a source-verifying condition. Not sure what ARN to use for Config (see notes below).
    # condition {
    #   test     = "ArnLike"       # StringLike, if using below keys
    #   variable = "aws:SourceArn" # OR aws:PrincipalOrgID ? OR aws:PrincipalOrgPaths ?
    #   values   = []
    # }
  }
}

#---------------------------------------------------------------------
### AWS Config - S3 Delivery Channel

resource "aws_config_delivery_channel" "Org_Config_Delivery_Channel" {
  count = local.IS_ROOT_ACCOUNT ? 1 : 0

  name           = var.org_aws_config.delivery_channel.name
  s3_bucket_name = var.org_aws_config.delivery_channel.s3_bucket.name
  s3_key_prefix  = var.org_aws_config.delivery_channel.s3_bucket.key_prefix
  s3_kms_key_arn = one(aws_kms_key.Org_KMS_Key).arn
  sns_topic_arn  = one(aws_sns_topic.Org_Config_SNS_Topic).arn

  snapshot_delivery_properties {
    delivery_frequency = coalesce(
      var.org_aws_config.delivery_channel.snapshot_frequency,
      "TwentyFour_Hours"
    )
  }

  depends_on = [aws_config_configuration_recorder.Org_Config_Recorder]
}

######################################################################
