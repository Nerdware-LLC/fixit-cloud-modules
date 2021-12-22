######################################################################
### AWS Config
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

  depends_on = [aws_iam_role_policy.Org_Config_Role_Policy]
}

#---------------------------------------------------------------------
### AWS Config - IAM Service Role

/* This role is used to make read or write requests to the delivery
channel and to describe the AWS resources associated with the account */
resource "aws_iam_role" "Org_Config_Role" {
  count = local.IS_ROOT_ACCOUNT ? 1 : 0

  name                = var.org_aws_config.service_role.name
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"]
  tags                = var.org_aws_config.service_role.tags
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowConfigServiceAssumeRole"
        Effect    = "Allow"
        Principal = { Service = "config.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "Org_Config_Role_Policy" {
  count = local.IS_ROOT_ACCOUNT ? 1 : 0

  name = var.org_aws_config.service_role.policy_name
  role = one(aws_iam_role.Org_Config_Role).id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Config IAM Role Policies --> S3 Bucket
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject", "s3:PutObjectAcl"]
        Resource = "${one(data.aws_s3_bucket.Org_Log_Archive_S3).arn}/*"
        Condition = {
          StringLike = { "s3:x-amz-acl" = "bucket-owner-full-control" }
        }
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetBucketAcl", "s3:ListBucket", "s3:GetBucketLocation"]
        Resource = one(data.aws_s3_bucket.Org_Log_Archive_S3).arn
      },
      # Config IAM Role Policies --> KMS Key
      {
        Effect   = "Allow"
        Action   = ["kms:Decrypt", "kms:GenerateDataKey"]
        Resource = one(aws_kms_key.Org_KMS_Key).arn
      },
      # Config IAM Role Policies --> SNS Topic
      {
        Effect   = "Allow"
        Action   = ["sns:Publish"]
        Resource = one(aws_sns_topic.Org_Config_SNS_Topic).arn
      }
    ]
  })
}

/* This data source ensures the "root" account doesn't need to explicitly provide
the ARN of the Org_Log_Archive_S3 bucket owned by the "Log-Archive" account.  */
data "aws_s3_bucket" "Org_Log_Archive_S3" {
  count = local.IS_ROOT_ACCOUNT ? 1 : 0

  bucket = var.org_log_archive_s3_bucket.name
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

  arn = one(aws_sns_topic.Org_Config_SNS_Topic).arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { AWS = one(aws_iam_role.Org_Config_Role).arn }
        Action    = ["sns:Publish"]
        Resource  = one(aws_sns_topic.Org_Config_SNS_Topic).arn
        Condition = {
          StringEquals = {
            "aws:PrincipalOrgID" = [local.org_id]
          }
        }
      }
    ]
  })
}

######################################################################
### REGION-SPECIFIC CONFIG RESOURCES

/* This data source ensures non-root accounts don't need to explicitly
provide the ARN of the Config IAM Role owned by the "root" account.  */
data "aws_iam_role" "Org_Config_Role" {
  count = local.IS_ROOT_ACCOUNT == false ? 1 : 0

  name = var.org_aws_config.service_role.name
}

data "aws_sns_topic" "Org_Config_SNS_Topic" { # TODO not sure if this will work... other accounts would need ListTopics action I think
  count = local.IS_ROOT_ACCOUNT == false ? 1 : 0

  name = var.org_aws_config.sns_topic.name
}

locals {
  delivery_frequency = coalesce(
    var.org_aws_config.delivery_channel.snapshot_frequency,
    "TwentyFour_Hours"
  )

  /* The below locals provide ARNs for resources owned by accounts
  other than the calling account. If the caller doesn't own the
  resource, the ARN comes from one of the above data blocks.  */
  config_iam_role_arn = (local.IS_ROOT_ACCOUNT
    ? one(aws_iam_role.Org_Config_Role).arn
    : one(data.aws_iam_role.Org_Config_Role).arn
  )

  config_sns_topic_arn = (local.IS_ROOT_ACCOUNT
    ? one(aws_sns_topic.Org_Config_SNS_Topic).arn
    : one(data.aws_sns_topic.Org_Config_SNS_Topic).arn
  )
}

#---------------------------------------------------------------------
### Config - us-east-2 (HOME REGION USES IMPLICIT/DEFAULT PROVIDER)

resource "aws_config_configuration_recorder" "us-east-2" {
  name     = var.org_aws_config.recorder_name
  role_arn = local.config_iam_role_arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = local.IS_ROOT_ACCOUNT == true # Only in us-east-2
  }
}

resource "aws_config_configuration_recorder_status" "us-east-2" {
  name       = aws_config_configuration_recorder.us-east-2.id
  is_enabled = true

  depends_on = [aws_config_delivery_channel.us-east-2]
}

resource "aws_config_delivery_channel" "us-east-2" {
  name           = var.org_aws_config.delivery_channel.name
  s3_bucket_name = var.org_aws_config.delivery_channel.s3_bucket.name
  s3_key_prefix  = var.org_aws_config.delivery_channel.s3_bucket.key_prefix
  s3_kms_key_arn = local.org_kms_key_alias
  sns_topic_arn  = local.config_sns_topic_arn

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_frequency
  }

  depends_on = [aws_config_configuration_recorder.us-east-2]
}

#---------------------------------------------------------------------
### Config - ap-northeast-1

resource "aws_config_configuration_recorder" "ap-northeast-1" {
  provider = aws.ap-northeast-1

  name     = var.org_aws_config.recorder_name
  role_arn = local.config_iam_role_arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = false
  }
}

resource "aws_config_configuration_recorder_status" "ap-northeast-1" {
  provider = aws.ap-northeast-1

  name       = aws_config_configuration_recorder.ap-northeast-1.id
  is_enabled = true

  depends_on = [aws_config_delivery_channel.ap-northeast-1]
}

resource "aws_config_delivery_channel" "ap-northeast-1" {
  provider = aws.ap-northeast-1

  name           = var.org_aws_config.delivery_channel.name
  s3_bucket_name = var.org_aws_config.delivery_channel.s3_bucket.name
  s3_key_prefix  = var.org_aws_config.delivery_channel.s3_bucket.key_prefix
  s3_kms_key_arn = local.org_kms_key_alias
  sns_topic_arn  = local.config_sns_topic_arn

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_frequency
  }

  depends_on = [aws_config_configuration_recorder.ap-northeast-1]
}

#---------------------------------------------------------------------
### Config - ap-northeast-2

resource "aws_config_configuration_recorder" "ap-northeast-2" {
  provider = aws.ap-northeast-2

  name     = var.org_aws_config.recorder_name
  role_arn = local.config_iam_role_arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = false
  }
}

resource "aws_config_configuration_recorder_status" "ap-northeast-2" {
  provider = aws.ap-northeast-2

  name       = aws_config_configuration_recorder.ap-northeast-2.id
  is_enabled = true

  depends_on = [aws_config_delivery_channel.ap-northeast-2]
}

resource "aws_config_delivery_channel" "ap-northeast-2" {
  provider = aws.ap-northeast-2

  name           = var.org_aws_config.delivery_channel.name
  s3_bucket_name = var.org_aws_config.delivery_channel.s3_bucket.name
  s3_key_prefix  = var.org_aws_config.delivery_channel.s3_bucket.key_prefix
  s3_kms_key_arn = local.org_kms_key_alias
  sns_topic_arn  = local.config_sns_topic_arn

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_frequency
  }

  depends_on = [aws_config_configuration_recorder.ap-northeast-2]
}

#---------------------------------------------------------------------
### Config - ap-northeast-3

resource "aws_config_configuration_recorder" "ap-northeast-3" {
  provider = aws.ap-northeast-3

  name     = var.org_aws_config.recorder_name
  role_arn = local.config_iam_role_arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = false
  }
}

resource "aws_config_configuration_recorder_status" "ap-northeast-3" {
  provider = aws.ap-northeast-3

  name       = aws_config_configuration_recorder.ap-northeast-3.id
  is_enabled = true

  depends_on = [aws_config_delivery_channel.ap-northeast-3]
}

resource "aws_config_delivery_channel" "ap-northeast-3" {
  provider = aws.ap-northeast-3

  name           = var.org_aws_config.delivery_channel.name
  s3_bucket_name = var.org_aws_config.delivery_channel.s3_bucket.name
  s3_key_prefix  = var.org_aws_config.delivery_channel.s3_bucket.key_prefix
  s3_kms_key_arn = local.org_kms_key_alias
  sns_topic_arn  = local.config_sns_topic_arn

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_frequency
  }

  depends_on = [aws_config_configuration_recorder.ap-northeast-3]
}

#---------------------------------------------------------------------
### Config - ap-south-1

resource "aws_config_configuration_recorder" "ap-south-1" {
  provider = aws.ap-south-1

  name     = var.org_aws_config.recorder_name
  role_arn = local.config_iam_role_arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = false
  }
}

resource "aws_config_configuration_recorder_status" "ap-south-1" {
  provider = aws.ap-south-1

  name       = aws_config_configuration_recorder.ap-south-1.id
  is_enabled = true

  depends_on = [aws_config_delivery_channel.ap-south-1]
}

resource "aws_config_delivery_channel" "ap-south-1" {
  provider = aws.ap-south-1

  name           = var.org_aws_config.delivery_channel.name
  s3_bucket_name = var.org_aws_config.delivery_channel.s3_bucket.name
  s3_key_prefix  = var.org_aws_config.delivery_channel.s3_bucket.key_prefix
  s3_kms_key_arn = local.org_kms_key_alias
  sns_topic_arn  = local.config_sns_topic_arn

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_frequency
  }

  depends_on = [aws_config_configuration_recorder.ap-south-1]
}

#---------------------------------------------------------------------
### Config - ap-southeast-1

resource "aws_config_configuration_recorder" "ap-southeast-1" {
  provider = aws.ap-southeast-1

  name     = var.org_aws_config.recorder_name
  role_arn = local.config_iam_role_arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = false
  }
}

resource "aws_config_configuration_recorder_status" "ap-southeast-1" {
  provider = aws.ap-southeast-1

  name       = aws_config_configuration_recorder.ap-southeast-1.id
  is_enabled = true

  depends_on = [aws_config_delivery_channel.ap-southeast-1]
}

resource "aws_config_delivery_channel" "ap-southeast-1" {
  provider = aws.ap-southeast-1

  name           = var.org_aws_config.delivery_channel.name
  s3_bucket_name = var.org_aws_config.delivery_channel.s3_bucket.name
  s3_key_prefix  = var.org_aws_config.delivery_channel.s3_bucket.key_prefix
  s3_kms_key_arn = local.org_kms_key_alias
  sns_topic_arn  = local.config_sns_topic_arn

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_frequency
  }

  depends_on = [aws_config_configuration_recorder.ap-southeast-1]
}

#---------------------------------------------------------------------
### Config - ap-southeast-2

resource "aws_config_configuration_recorder" "ap-southeast-2" {
  provider = aws.ap-southeast-2

  name     = var.org_aws_config.recorder_name
  role_arn = local.config_iam_role_arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = false
  }
}

resource "aws_config_configuration_recorder_status" "ap-southeast-2" {
  provider = aws.ap-southeast-2

  name       = aws_config_configuration_recorder.ap-southeast-2.id
  is_enabled = true

  depends_on = [aws_config_delivery_channel.ap-southeast-2]
}

resource "aws_config_delivery_channel" "ap-southeast-2" {
  provider = aws.ap-southeast-2

  name           = var.org_aws_config.delivery_channel.name
  s3_bucket_name = var.org_aws_config.delivery_channel.s3_bucket.name
  s3_key_prefix  = var.org_aws_config.delivery_channel.s3_bucket.key_prefix
  s3_kms_key_arn = local.org_kms_key_alias
  sns_topic_arn  = local.config_sns_topic_arn

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_frequency
  }

  depends_on = [aws_config_configuration_recorder.ap-southeast-2]
}

#---------------------------------------------------------------------
### Config - ca-central-1

resource "aws_config_configuration_recorder" "ca-central-1" {
  provider = aws.ca-central-1

  name     = var.org_aws_config.recorder_name
  role_arn = local.config_iam_role_arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = false
  }
}

resource "aws_config_configuration_recorder_status" "ca-central-1" {
  provider = aws.ca-central-1

  name       = aws_config_configuration_recorder.ca-central-1.id
  is_enabled = true

  depends_on = [aws_config_delivery_channel.ca-central-1]
}

resource "aws_config_delivery_channel" "ca-central-1" {
  provider = aws.ca-central-1

  name           = var.org_aws_config.delivery_channel.name
  s3_bucket_name = var.org_aws_config.delivery_channel.s3_bucket.name
  s3_key_prefix  = var.org_aws_config.delivery_channel.s3_bucket.key_prefix
  s3_kms_key_arn = local.org_kms_key_alias
  sns_topic_arn  = local.config_sns_topic_arn

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_frequency
  }

  depends_on = [aws_config_configuration_recorder.ca-central-1]
}

#---------------------------------------------------------------------
### Config - eu-north-1

resource "aws_config_configuration_recorder" "eu-north-1" {
  provider = aws.eu-north-1

  name     = var.org_aws_config.recorder_name
  role_arn = local.config_iam_role_arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = false
  }
}

resource "aws_config_configuration_recorder_status" "eu-north-1" {
  provider = aws.eu-north-1

  name       = aws_config_configuration_recorder.eu-north-1.id
  is_enabled = true

  depends_on = [aws_config_delivery_channel.eu-north-1]
}

resource "aws_config_delivery_channel" "eu-north-1" {
  provider = aws.eu-north-1

  name           = var.org_aws_config.delivery_channel.name
  s3_bucket_name = var.org_aws_config.delivery_channel.s3_bucket.name
  s3_key_prefix  = var.org_aws_config.delivery_channel.s3_bucket.key_prefix
  s3_kms_key_arn = local.org_kms_key_alias
  sns_topic_arn  = local.config_sns_topic_arn

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_frequency
  }

  depends_on = [aws_config_configuration_recorder.eu-north-1]
}

#---------------------------------------------------------------------
### Config - eu-central-1

resource "aws_config_configuration_recorder" "eu-central-1" {
  provider = aws.eu-central-1

  name     = var.org_aws_config.recorder_name
  role_arn = local.config_iam_role_arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = false
  }
}

resource "aws_config_configuration_recorder_status" "eu-central-1" {
  provider = aws.eu-central-1

  name       = aws_config_configuration_recorder.eu-central-1.id
  is_enabled = true

  depends_on = [aws_config_delivery_channel.eu-central-1]
}

resource "aws_config_delivery_channel" "eu-central-1" {
  provider = aws.eu-central-1

  name           = var.org_aws_config.delivery_channel.name
  s3_bucket_name = var.org_aws_config.delivery_channel.s3_bucket.name
  s3_key_prefix  = var.org_aws_config.delivery_channel.s3_bucket.key_prefix
  s3_kms_key_arn = local.org_kms_key_alias
  sns_topic_arn  = local.config_sns_topic_arn

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_frequency
  }

  depends_on = [aws_config_configuration_recorder.eu-central-1]
}

#---------------------------------------------------------------------
### Config - eu-west-1

resource "aws_config_configuration_recorder" "eu-west-1" {
  provider = aws.eu-west-1

  name     = var.org_aws_config.recorder_name
  role_arn = local.config_iam_role_arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = false
  }
}

resource "aws_config_configuration_recorder_status" "eu-west-1" {
  provider = aws.eu-west-1

  name       = aws_config_configuration_recorder.eu-west-1.id
  is_enabled = true

  depends_on = [aws_config_delivery_channel.eu-west-1]
}

resource "aws_config_delivery_channel" "eu-west-1" {
  provider = aws.eu-west-1

  name           = var.org_aws_config.delivery_channel.name
  s3_bucket_name = var.org_aws_config.delivery_channel.s3_bucket.name
  s3_key_prefix  = var.org_aws_config.delivery_channel.s3_bucket.key_prefix
  s3_kms_key_arn = local.org_kms_key_alias
  sns_topic_arn  = local.config_sns_topic_arn

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_frequency
  }

  depends_on = [aws_config_configuration_recorder.eu-west-1]
}

#---------------------------------------------------------------------
### Config - eu-west-2

resource "aws_config_configuration_recorder" "eu-west-2" {
  provider = aws.eu-west-2

  name     = var.org_aws_config.recorder_name
  role_arn = local.config_iam_role_arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = false
  }
}

resource "aws_config_configuration_recorder_status" "eu-west-2" {
  provider = aws.eu-west-2

  name       = aws_config_configuration_recorder.eu-west-2.id
  is_enabled = true

  depends_on = [aws_config_delivery_channel.eu-west-2]
}

resource "aws_config_delivery_channel" "eu-west-2" {
  provider = aws.eu-west-2

  name           = var.org_aws_config.delivery_channel.name
  s3_bucket_name = var.org_aws_config.delivery_channel.s3_bucket.name
  s3_key_prefix  = var.org_aws_config.delivery_channel.s3_bucket.key_prefix
  s3_kms_key_arn = local.org_kms_key_alias
  sns_topic_arn  = local.config_sns_topic_arn

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_frequency
  }

  depends_on = [aws_config_configuration_recorder.eu-west-2]
}

#---------------------------------------------------------------------
### Config - eu-west-3

resource "aws_config_configuration_recorder" "eu-west-3" {
  provider = aws.eu-west-3

  name     = var.org_aws_config.recorder_name
  role_arn = local.config_iam_role_arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = false
  }
}

resource "aws_config_configuration_recorder_status" "eu-west-3" {
  provider = aws.eu-west-3

  name       = aws_config_configuration_recorder.eu-west-3.id
  is_enabled = true

  depends_on = [aws_config_delivery_channel.eu-west-3]
}

resource "aws_config_delivery_channel" "eu-west-3" {
  provider = aws.eu-west-3

  name           = var.org_aws_config.delivery_channel.name
  s3_bucket_name = var.org_aws_config.delivery_channel.s3_bucket.name
  s3_key_prefix  = var.org_aws_config.delivery_channel.s3_bucket.key_prefix
  s3_kms_key_arn = local.org_kms_key_alias
  sns_topic_arn  = local.config_sns_topic_arn

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_frequency
  }

  depends_on = [aws_config_configuration_recorder.eu-west-3]
}

#---------------------------------------------------------------------
### Config - sa-east-1

resource "aws_config_configuration_recorder" "sa-east-1" {
  provider = aws.sa-east-1

  name     = var.org_aws_config.recorder_name
  role_arn = local.config_iam_role_arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = false
  }
}

resource "aws_config_configuration_recorder_status" "sa-east-1" {
  provider = aws.sa-east-1

  name       = aws_config_configuration_recorder.sa-east-1.id
  is_enabled = true

  depends_on = [aws_config_delivery_channel.sa-east-1]
}

resource "aws_config_delivery_channel" "sa-east-1" {
  provider = aws.sa-east-1

  name           = var.org_aws_config.delivery_channel.name
  s3_bucket_name = var.org_aws_config.delivery_channel.s3_bucket.name
  s3_key_prefix  = var.org_aws_config.delivery_channel.s3_bucket.key_prefix
  s3_kms_key_arn = local.org_kms_key_alias
  sns_topic_arn  = local.config_sns_topic_arn

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_frequency
  }

  depends_on = [aws_config_configuration_recorder.sa-east-1]
}

#---------------------------------------------------------------------
### Config - us-east-1

resource "aws_config_configuration_recorder" "us-east-1" {
  provider = aws.us-east-1

  name     = var.org_aws_config.recorder_name
  role_arn = local.config_iam_role_arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = false
  }
}

resource "aws_config_configuration_recorder_status" "us-east-1" {
  provider = aws.us-east-1

  name       = aws_config_configuration_recorder.us-east-1.id
  is_enabled = true

  depends_on = [aws_config_delivery_channel.us-east-1]
}

resource "aws_config_delivery_channel" "us-east-1" {
  provider = aws.us-east-1

  name           = var.org_aws_config.delivery_channel.name
  s3_bucket_name = var.org_aws_config.delivery_channel.s3_bucket.name
  s3_key_prefix  = var.org_aws_config.delivery_channel.s3_bucket.key_prefix
  s3_kms_key_arn = local.org_kms_key_alias
  sns_topic_arn  = local.config_sns_topic_arn

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_frequency
  }

  depends_on = [aws_config_configuration_recorder.us-east-1]
}

#---------------------------------------------------------------------
### Config - us-west-1

resource "aws_config_configuration_recorder" "us-west-1" {
  provider = aws.us-west-1

  name     = var.org_aws_config.recorder_name
  role_arn = local.config_iam_role_arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = false
  }
}

resource "aws_config_configuration_recorder_status" "us-west-1" {
  provider = aws.us-west-1

  name       = aws_config_configuration_recorder.us-west-1.id
  is_enabled = true

  depends_on = [aws_config_delivery_channel.us-west-1]
}

resource "aws_config_delivery_channel" "us-west-1" {
  provider = aws.us-west-1

  name           = var.org_aws_config.delivery_channel.name
  s3_bucket_name = var.org_aws_config.delivery_channel.s3_bucket.name
  s3_key_prefix  = var.org_aws_config.delivery_channel.s3_bucket.key_prefix
  s3_kms_key_arn = local.org_kms_key_alias
  sns_topic_arn  = local.config_sns_topic_arn

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_frequency
  }

  depends_on = [aws_config_configuration_recorder.us-west-1]
}

#---------------------------------------------------------------------
### Config - us-west-2

resource "aws_config_configuration_recorder" "us-west-2" {
  provider = aws.us-west-2

  name     = var.org_aws_config.recorder_name
  role_arn = local.config_iam_role_arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = false
  }
}

resource "aws_config_configuration_recorder_status" "us-west-2" {
  provider = aws.us-west-2

  name       = aws_config_configuration_recorder.us-west-2.id
  is_enabled = true

  depends_on = [aws_config_delivery_channel.us-west-2]
}

resource "aws_config_delivery_channel" "us-west-2" {
  provider = aws.us-west-2

  name           = var.org_aws_config.delivery_channel.name
  s3_bucket_name = var.org_aws_config.delivery_channel.s3_bucket.name
  s3_key_prefix  = var.org_aws_config.delivery_channel.s3_bucket.key_prefix
  s3_kms_key_arn = local.org_kms_key_alias
  sns_topic_arn  = local.config_sns_topic_arn

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_frequency
  }

  depends_on = [aws_config_configuration_recorder.us-west-2]
}

######################################################################
