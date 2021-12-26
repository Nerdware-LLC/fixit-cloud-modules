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
    role_arn    = one(aws_iam_role.Org_Config_Aggregator_Role).arn
  }

  depends_on = [aws_iam_role_policy_attachment.Org_Config_Aggregator_Role_Policy]
}

resource "aws_iam_role" "Org_Config_Aggregator_Role" {
  count = local.IS_ROOT_ACCOUNT ? 1 : 0

  name        = var.org_aws_config.aggregator.service_role.name
  description = var.org_aws_config.aggregator.service_role.description
  tags        = var.org_aws_config.aggregator.service_role.tags
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

resource "aws_iam_role_policy_attachment" "Org_Config_Aggregator_Role_Policy" {
  count = local.IS_ROOT_ACCOUNT ? 1 : 0

  role       = one(aws_iam_role.Org_Config_Aggregator_Role).name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRoleForOrganizations"
}

#---------------------------------------------------------------------
### AWS Config - IAM Service Role

/* This role is used to make read or write requests to the delivery
channel and to describe the AWS resources associated with the account */
resource "aws_iam_role" "Org_Config_Role" {
  name        = var.org_aws_config.service_role.name
  description = var.org_aws_config.service_role.description
  tags        = var.org_aws_config.service_role.tags
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

resource "aws_iam_policy" "Org_Config_Role_Policy" {
  count = local.IS_ROOT_ACCOUNT ? 1 : 0

  name        = var.org_aws_config.service_role.policy.name
  description = var.org_aws_config.service_role.policy.description
  path        = var.org_aws_config.service_role.policy.path
  tags        = var.org_aws_config.service_role.policy.tags
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Config IAM Role Policies --> S3 Bucket
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject", "s3:PutObjectAcl"]
        Resource = "arn:aws:s3:::${var.org_log_archive_s3_bucket.name}/*"
        Condition = {
          StringLike = { "s3:x-amz-acl" = "bucket-owner-full-control" }
        }
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetBucketAcl", "s3:ListBucket", "s3:GetBucketLocation"]
        Resource = "arn:aws:s3:::${var.org_log_archive_s3_bucket.name}"
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
        Resource = "arn:aws:sns:*:${local.root_account_id}:${var.org_aws_config.sns_topic.name}"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "Org_Config_Role_Policies" {
  for_each = {
    "${var.org_aws_config.service_role.policy.name}" = "arn:aws:iam::${local.root_account_id}:policy/${var.org_aws_config.service_role.policy.name}"
    AWS_ConfigRole                                   = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
  }

  role       = aws_iam_role.Org_Config_Role.name
  policy_arn = each.value

  depends_on = [aws_iam_policy.Org_Config_Role_Policy] # For root account
}

######################################################################
### REGION-SPECIFIC CONFIG RESOURCES

locals {
  delivery_channel_snapshot_frequency = coalesce(
    var.org_aws_config.delivery_channel.snapshot_frequency,
    "TwentyFour_Hours"
  )
}

#---------------------------------------------------------------------
### Config - us-east-2 (HOME REGION USES IMPLICIT/DEFAULT PROVIDER)

resource "aws_config_configuration_recorder" "us-east-2" {
  name     = var.org_aws_config.recorder_name
  role_arn = aws_iam_role.Org_Config_Role.arn

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
  s3_kms_key_arn = "arn:aws:kms:us-east-2:${local.root_account_id}:alias/${var.org_kms_key.alias_name}"
  sns_topic_arn  = "arn:aws:sns:us-east-2:${local.root_account_id}:${var.org_aws_config.sns_topic.name}"

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_channel_snapshot_frequency
  }

  depends_on = [aws_config_configuration_recorder.us-east-2]
}

resource "aws_sns_topic" "us-east-2" {
  count = local.IS_ROOT_ACCOUNT ? 1 : 0

  name              = var.org_aws_config.sns_topic.name
  display_name      = var.org_aws_config.sns_topic.display_name
  kms_master_key_id = one(aws_kms_key.Org_KMS_Key).id
  tags              = var.org_aws_config.sns_topic.tags
}

resource "aws_sns_topic_policy" "us-east-2" {
  count = local.IS_ROOT_ACCOUNT ? 1 : 0

  arn = one(aws_sns_topic.us-east-2).arn
  policy = templatefile("${path.module}/templates/Config_SNS_Topic_Policy.tftpl", {
    sns_topic_arn                = one(aws_sns_topic.us-east-2).arn
    config_iam_service_role_name = var.org_aws_config.service_role.name
    region                       = "us-east-2"
    root_account_id              = local.root_account_id
    org_id                       = local.org_id
  })
}

#---------------------------------------------------------------------
### Config - ap-northeast-1

resource "aws_config_configuration_recorder" "ap-northeast-1" {
  provider = aws.ap-northeast-1

  name     = var.org_aws_config.recorder_name
  role_arn = aws_iam_role.Org_Config_Role.arn

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
  s3_kms_key_arn = "arn:aws:kms:ap-northeast-1:${local.root_account_id}:alias/${var.org_kms_key.alias_name}"
  sns_topic_arn  = "arn:aws:sns:ap-northeast-1:${local.root_account_id}:${var.org_aws_config.sns_topic.name}"

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_channel_snapshot_frequency
  }

  depends_on = [aws_config_configuration_recorder.ap-northeast-1]
}

resource "aws_sns_topic" "ap-northeast-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.ap-northeast-1

  name              = var.org_aws_config.sns_topic.name
  display_name      = var.org_aws_config.sns_topic.display_name
  kms_master_key_id = one(aws_kms_key.Org_KMS_Key).id
  tags              = var.org_aws_config.sns_topic.tags
}

resource "aws_sns_topic_policy" "ap-northeast-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.ap-northeast-1

  arn = one(aws_sns_topic.ap-northeast-1).arn
  policy = templatefile("${path.module}/templates/Config_SNS_Topic_Policy.tftpl", {
    sns_topic_arn                = one(aws_sns_topic.ap-northeast-1).arn
    config_iam_service_role_name = var.org_aws_config.service_role.name
    region                       = "ap-northeast-1"
    root_account_id              = local.root_account_id
    org_id                       = local.org_id
  })
}

#---------------------------------------------------------------------
### Config - ap-northeast-2

resource "aws_config_configuration_recorder" "ap-northeast-2" {
  provider = aws.ap-northeast-2

  name     = var.org_aws_config.recorder_name
  role_arn = aws_iam_role.Org_Config_Role.arn

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
  s3_kms_key_arn = "arn:aws:kms:ap-northeast-2:${local.root_account_id}:alias/${var.org_kms_key.alias_name}"
  sns_topic_arn  = "arn:aws:sns:ap-northeast-2:${local.root_account_id}:${var.org_aws_config.sns_topic.name}"

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_channel_snapshot_frequency
  }

  depends_on = [aws_config_configuration_recorder.ap-northeast-2]
}

resource "aws_sns_topic" "ap-northeast-2" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.ap-northeast-2

  name              = var.org_aws_config.sns_topic.name
  display_name      = var.org_aws_config.sns_topic.display_name
  kms_master_key_id = one(aws_kms_key.Org_KMS_Key).id
  tags              = var.org_aws_config.sns_topic.tags
}

resource "aws_sns_topic_policy" "ap-northeast-2" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.ap-northeast-2

  arn = one(aws_sns_topic.ap-northeast-2).arn
  policy = templatefile("${path.module}/templates/Config_SNS_Topic_Policy.tftpl", {
    sns_topic_arn                = one(aws_sns_topic.ap-northeast-2).arn
    config_iam_service_role_name = var.org_aws_config.service_role.name
    region                       = "ap-northeast-2"
    root_account_id              = local.root_account_id
    org_id                       = local.org_id
  })
}

#---------------------------------------------------------------------
### Config - ap-northeast-3

resource "aws_config_configuration_recorder" "ap-northeast-3" {
  provider = aws.ap-northeast-3

  name     = var.org_aws_config.recorder_name
  role_arn = aws_iam_role.Org_Config_Role.arn

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
  s3_kms_key_arn = "arn:aws:kms:ap-northeast-3:${local.root_account_id}:alias/${var.org_kms_key.alias_name}"
  sns_topic_arn  = "arn:aws:sns:ap-northeast-3:${local.root_account_id}:${var.org_aws_config.sns_topic.name}"

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_channel_snapshot_frequency
  }

  depends_on = [aws_config_configuration_recorder.ap-northeast-3]
}

resource "aws_sns_topic" "ap-northeast-3" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.ap-northeast-3

  name              = var.org_aws_config.sns_topic.name
  display_name      = var.org_aws_config.sns_topic.display_name
  kms_master_key_id = one(aws_kms_key.Org_KMS_Key).id
  tags              = var.org_aws_config.sns_topic.tags
}

resource "aws_sns_topic_policy" "ap-northeast-3" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.ap-northeast-3

  arn = one(aws_sns_topic.ap-northeast-3).arn
  policy = templatefile("${path.module}/templates/Config_SNS_Topic_Policy.tftpl", {
    sns_topic_arn                = one(aws_sns_topic.ap-northeast-3).arn
    config_iam_service_role_name = var.org_aws_config.service_role.name
    region                       = "ap-northeast-3"
    root_account_id              = local.root_account_id
    org_id                       = local.org_id
  })
}

#---------------------------------------------------------------------
### Config - ap-south-1

resource "aws_config_configuration_recorder" "ap-south-1" {
  provider = aws.ap-south-1

  name     = var.org_aws_config.recorder_name
  role_arn = aws_iam_role.Org_Config_Role.arn

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
  s3_kms_key_arn = "arn:aws:kms:ap-south-1:${local.root_account_id}:alias/${var.org_kms_key.alias_name}"
  sns_topic_arn  = "arn:aws:sns:ap-south-1:${local.root_account_id}:${var.org_aws_config.sns_topic.name}"

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_channel_snapshot_frequency
  }

  depends_on = [aws_config_configuration_recorder.ap-south-1]
}

resource "aws_sns_topic" "ap-south-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.ap-south-1

  name              = var.org_aws_config.sns_topic.name
  display_name      = var.org_aws_config.sns_topic.display_name
  kms_master_key_id = one(aws_kms_key.Org_KMS_Key).id
  tags              = var.org_aws_config.sns_topic.tags
}

resource "aws_sns_topic_policy" "ap-south-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.ap-south-1

  arn = one(aws_sns_topic.ap-south-1).arn
  policy = templatefile("${path.module}/templates/Config_SNS_Topic_Policy.tftpl", {
    sns_topic_arn                = one(aws_sns_topic.ap-south-1).arn
    config_iam_service_role_name = var.org_aws_config.service_role.name
    region                       = "ap-south-1"
    root_account_id              = local.root_account_id
    org_id                       = local.org_id
  })
}

#---------------------------------------------------------------------
### Config - ap-southeast-1

resource "aws_config_configuration_recorder" "ap-southeast-1" {
  provider = aws.ap-southeast-1

  name     = var.org_aws_config.recorder_name
  role_arn = aws_iam_role.Org_Config_Role.arn

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
  s3_kms_key_arn = "arn:aws:kms:ap-southeast-1:${local.root_account_id}:alias/${var.org_kms_key.alias_name}"
  sns_topic_arn  = "arn:aws:sns:ap-southeast-1:${local.root_account_id}:${var.org_aws_config.sns_topic.name}"

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_channel_snapshot_frequency
  }

  depends_on = [aws_config_configuration_recorder.ap-southeast-1]
}

resource "aws_sns_topic" "ap-southeast-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.ap-southeast-1

  name              = var.org_aws_config.sns_topic.name
  display_name      = var.org_aws_config.sns_topic.display_name
  kms_master_key_id = one(aws_kms_key.Org_KMS_Key).id
  tags              = var.org_aws_config.sns_topic.tags
}

resource "aws_sns_topic_policy" "ap-southeast-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.ap-southeast-1

  arn = one(aws_sns_topic.ap-southeast-1).arn
  policy = templatefile("${path.module}/templates/Config_SNS_Topic_Policy.tftpl", {
    sns_topic_arn                = one(aws_sns_topic.ap-southeast-1).arn
    config_iam_service_role_name = var.org_aws_config.service_role.name
    region                       = "ap-southeast-1"
    root_account_id              = local.root_account_id
    org_id                       = local.org_id
  })
}

#---------------------------------------------------------------------
### Config - ap-southeast-2

resource "aws_config_configuration_recorder" "ap-southeast-2" {
  provider = aws.ap-southeast-2

  name     = var.org_aws_config.recorder_name
  role_arn = aws_iam_role.Org_Config_Role.arn

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
  s3_kms_key_arn = "arn:aws:kms:ap-southeast-2:${local.root_account_id}:alias/${var.org_kms_key.alias_name}"
  sns_topic_arn  = "arn:aws:sns:ap-southeast-2:${local.root_account_id}:${var.org_aws_config.sns_topic.name}"

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_channel_snapshot_frequency
  }

  depends_on = [aws_config_configuration_recorder.ap-southeast-2]
}

resource "aws_sns_topic" "ap-southeast-2" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.ap-southeast-2

  name              = var.org_aws_config.sns_topic.name
  display_name      = var.org_aws_config.sns_topic.display_name
  kms_master_key_id = one(aws_kms_key.Org_KMS_Key).id
  tags              = var.org_aws_config.sns_topic.tags
}

resource "aws_sns_topic_policy" "ap-southeast-2" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.ap-southeast-2

  arn = one(aws_sns_topic.ap-southeast-2).arn
  policy = templatefile("${path.module}/templates/Config_SNS_Topic_Policy.tftpl", {
    sns_topic_arn                = one(aws_sns_topic.ap-southeast-2).arn
    config_iam_service_role_name = var.org_aws_config.service_role.name
    region                       = "ap-southeast-2"
    root_account_id              = local.root_account_id
    org_id                       = local.org_id
  })
}

#---------------------------------------------------------------------
### Config - ca-central-1

resource "aws_config_configuration_recorder" "ca-central-1" {
  provider = aws.ca-central-1

  name     = var.org_aws_config.recorder_name
  role_arn = aws_iam_role.Org_Config_Role.arn

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
  s3_kms_key_arn = "arn:aws:kms:ca-central-1:${local.root_account_id}:alias/${var.org_kms_key.alias_name}"
  sns_topic_arn  = "arn:aws:sns:ca-central-1:${local.root_account_id}:${var.org_aws_config.sns_topic.name}"

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_channel_snapshot_frequency
  }

  depends_on = [aws_config_configuration_recorder.ca-central-1]
}

resource "aws_sns_topic" "ca-central-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.ca-central-1

  name              = var.org_aws_config.sns_topic.name
  display_name      = var.org_aws_config.sns_topic.display_name
  kms_master_key_id = one(aws_kms_key.Org_KMS_Key).id
  tags              = var.org_aws_config.sns_topic.tags
}

resource "aws_sns_topic_policy" "ca-central-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.ca-central-1

  arn = one(aws_sns_topic.ca-central-1).arn
  policy = templatefile("${path.module}/templates/Config_SNS_Topic_Policy.tftpl", {
    sns_topic_arn                = one(aws_sns_topic.ca-central-1).arn
    config_iam_service_role_name = var.org_aws_config.service_role.name
    region                       = "ca-central-1"
    root_account_id              = local.root_account_id
    org_id                       = local.org_id
  })
}

#---------------------------------------------------------------------
### Config - eu-north-1

resource "aws_config_configuration_recorder" "eu-north-1" {
  provider = aws.eu-north-1

  name     = var.org_aws_config.recorder_name
  role_arn = aws_iam_role.Org_Config_Role.arn

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
  s3_kms_key_arn = "arn:aws:kms:eu-north-1:${local.root_account_id}:alias/${var.org_kms_key.alias_name}"
  sns_topic_arn  = "arn:aws:sns:eu-north-1:${local.root_account_id}:${var.org_aws_config.sns_topic.name}"

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_channel_snapshot_frequency
  }

  depends_on = [aws_config_configuration_recorder.eu-north-1]
}

resource "aws_sns_topic" "eu-north-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.eu-north-1

  name              = var.org_aws_config.sns_topic.name
  display_name      = var.org_aws_config.sns_topic.display_name
  kms_master_key_id = one(aws_kms_key.Org_KMS_Key).id
  tags              = var.org_aws_config.sns_topic.tags
}

resource "aws_sns_topic_policy" "eu-north-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.eu-north-1

  arn = one(aws_sns_topic.eu-north-1).arn
  policy = templatefile("${path.module}/templates/Config_SNS_Topic_Policy.tftpl", {
    sns_topic_arn                = one(aws_sns_topic.eu-north-1).arn
    config_iam_service_role_name = var.org_aws_config.service_role.name
    region                       = "eu-north-1"
    root_account_id              = local.root_account_id
    org_id                       = local.org_id
  })
}

#---------------------------------------------------------------------
### Config - eu-central-1

resource "aws_config_configuration_recorder" "eu-central-1" {
  provider = aws.eu-central-1

  name     = var.org_aws_config.recorder_name
  role_arn = aws_iam_role.Org_Config_Role.arn

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
  s3_kms_key_arn = "arn:aws:kms:eu-central-1:${local.root_account_id}:alias/${var.org_kms_key.alias_name}"
  sns_topic_arn  = "arn:aws:sns:eu-central-1:${local.root_account_id}:${var.org_aws_config.sns_topic.name}"

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_channel_snapshot_frequency
  }

  depends_on = [aws_config_configuration_recorder.eu-central-1]
}

resource "aws_sns_topic" "eu-central-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.eu-central-1

  name              = var.org_aws_config.sns_topic.name
  display_name      = var.org_aws_config.sns_topic.display_name
  kms_master_key_id = one(aws_kms_key.Org_KMS_Key).id
  tags              = var.org_aws_config.sns_topic.tags
}

resource "aws_sns_topic_policy" "eu-central-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.eu-central-1

  arn = one(aws_sns_topic.eu-central-1).arn
  policy = templatefile("${path.module}/templates/Config_SNS_Topic_Policy.tftpl", {
    sns_topic_arn                = one(aws_sns_topic.eu-central-1).arn
    config_iam_service_role_name = var.org_aws_config.service_role.name
    region                       = "eu-central-1"
    root_account_id              = local.root_account_id
    org_id                       = local.org_id
  })
}

#---------------------------------------------------------------------
### Config - eu-west-1

resource "aws_config_configuration_recorder" "eu-west-1" {
  provider = aws.eu-west-1

  name     = var.org_aws_config.recorder_name
  role_arn = aws_iam_role.Org_Config_Role.arn

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
  s3_kms_key_arn = "arn:aws:kms:eu-west-1:${local.root_account_id}:alias/${var.org_kms_key.alias_name}"
  sns_topic_arn  = "arn:aws:sns:eu-west-1:${local.root_account_id}:${var.org_aws_config.sns_topic.name}"

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_channel_snapshot_frequency
  }

  depends_on = [aws_config_configuration_recorder.eu-west-1]
}

resource "aws_sns_topic" "eu-west-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.eu-west-1

  name              = var.org_aws_config.sns_topic.name
  display_name      = var.org_aws_config.sns_topic.display_name
  kms_master_key_id = one(aws_kms_key.Org_KMS_Key).id
  tags              = var.org_aws_config.sns_topic.tags
}

resource "aws_sns_topic_policy" "eu-west-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.eu-west-1

  arn = one(aws_sns_topic.eu-west-1).arn
  policy = templatefile("${path.module}/templates/Config_SNS_Topic_Policy.tftpl", {
    sns_topic_arn                = one(aws_sns_topic.eu-west-1).arn
    config_iam_service_role_name = var.org_aws_config.service_role.name
    region                       = "eu-west-1"
    root_account_id              = local.root_account_id
    org_id                       = local.org_id
  })
}

#---------------------------------------------------------------------
### Config - eu-west-2

resource "aws_config_configuration_recorder" "eu-west-2" {
  provider = aws.eu-west-2

  name     = var.org_aws_config.recorder_name
  role_arn = aws_iam_role.Org_Config_Role.arn

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
  s3_kms_key_arn = "arn:aws:kms:eu-west-2:${local.root_account_id}:alias/${var.org_kms_key.alias_name}"
  sns_topic_arn  = "arn:aws:sns:eu-west-2:${local.root_account_id}:${var.org_aws_config.sns_topic.name}"

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_channel_snapshot_frequency
  }

  depends_on = [aws_config_configuration_recorder.eu-west-2]
}

resource "aws_sns_topic" "eu-west-2" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.eu-west-2

  name              = var.org_aws_config.sns_topic.name
  display_name      = var.org_aws_config.sns_topic.display_name
  kms_master_key_id = one(aws_kms_key.Org_KMS_Key).id
  tags              = var.org_aws_config.sns_topic.tags
}

resource "aws_sns_topic_policy" "eu-west-2" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.eu-west-2

  arn = one(aws_sns_topic.eu-west-2).arn
  policy = templatefile("${path.module}/templates/Config_SNS_Topic_Policy.tftpl", {
    sns_topic_arn                = one(aws_sns_topic.eu-west-2).arn
    config_iam_service_role_name = var.org_aws_config.service_role.name
    region                       = "eu-west-2"
    root_account_id              = local.root_account_id
    org_id                       = local.org_id
  })
}

#---------------------------------------------------------------------
### Config - eu-west-3

resource "aws_config_configuration_recorder" "eu-west-3" {
  provider = aws.eu-west-3

  name     = var.org_aws_config.recorder_name
  role_arn = aws_iam_role.Org_Config_Role.arn

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
  s3_kms_key_arn = "arn:aws:kms:eu-west-3:${local.root_account_id}:alias/${var.org_kms_key.alias_name}"
  sns_topic_arn  = "arn:aws:sns:eu-west-3:${local.root_account_id}:${var.org_aws_config.sns_topic.name}"

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_channel_snapshot_frequency
  }

  depends_on = [aws_config_configuration_recorder.eu-west-3]
}

resource "aws_sns_topic" "eu-west-3" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.eu-west-3

  name              = var.org_aws_config.sns_topic.name
  display_name      = var.org_aws_config.sns_topic.display_name
  kms_master_key_id = one(aws_kms_key.Org_KMS_Key).id
  tags              = var.org_aws_config.sns_topic.tags
}

resource "aws_sns_topic_policy" "eu-west-3" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.eu-west-3

  arn = one(aws_sns_topic.eu-west-3).arn
  policy = templatefile("${path.module}/templates/Config_SNS_Topic_Policy.tftpl", {
    sns_topic_arn                = one(aws_sns_topic.eu-west-3).arn
    config_iam_service_role_name = var.org_aws_config.service_role.name
    region                       = "eu-west-3"
    root_account_id              = local.root_account_id
    org_id                       = local.org_id
  })
}

#---------------------------------------------------------------------
### Config - sa-east-1

resource "aws_config_configuration_recorder" "sa-east-1" {
  provider = aws.sa-east-1

  name     = var.org_aws_config.recorder_name
  role_arn = aws_iam_role.Org_Config_Role.arn

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
  s3_kms_key_arn = "arn:aws:kms:sa-east-1:${local.root_account_id}:alias/${var.org_kms_key.alias_name}"
  sns_topic_arn  = "arn:aws:sns:sa-east-1:${local.root_account_id}:${var.org_aws_config.sns_topic.name}"

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_channel_snapshot_frequency
  }

  depends_on = [aws_config_configuration_recorder.sa-east-1]
}

resource "aws_sns_topic" "sa-east-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.sa-east-1

  name              = var.org_aws_config.sns_topic.name
  display_name      = var.org_aws_config.sns_topic.display_name
  kms_master_key_id = one(aws_kms_key.Org_KMS_Key).id
  tags              = var.org_aws_config.sns_topic.tags
}

resource "aws_sns_topic_policy" "sa-east-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.sa-east-1

  arn = one(aws_sns_topic.sa-east-1).arn
  policy = templatefile("${path.module}/templates/Config_SNS_Topic_Policy.tftpl", {
    sns_topic_arn                = one(aws_sns_topic.sa-east-1).arn
    config_iam_service_role_name = var.org_aws_config.service_role.name
    region                       = "sa-east-1"
    root_account_id              = local.root_account_id
    org_id                       = local.org_id
  })
}

#---------------------------------------------------------------------
### Config - us-east-1

resource "aws_config_configuration_recorder" "us-east-1" {
  provider = aws.us-east-1

  name     = var.org_aws_config.recorder_name
  role_arn = aws_iam_role.Org_Config_Role.arn

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
  s3_kms_key_arn = "arn:aws:kms:us-east-1:${local.root_account_id}:alias/${var.org_kms_key.alias_name}"
  sns_topic_arn  = "arn:aws:sns:us-east-1:${local.root_account_id}:${var.org_aws_config.sns_topic.name}"

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_channel_snapshot_frequency
  }

  depends_on = [aws_config_configuration_recorder.us-east-1]
}

resource "aws_sns_topic" "us-east-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.us-east-1

  name              = var.org_aws_config.sns_topic.name
  display_name      = var.org_aws_config.sns_topic.display_name
  kms_master_key_id = one(aws_kms_key.Org_KMS_Key).id
  tags              = var.org_aws_config.sns_topic.tags
}

resource "aws_sns_topic_policy" "us-east-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.us-east-1

  arn = one(aws_sns_topic.us-east-1).arn
  policy = templatefile("${path.module}/templates/Config_SNS_Topic_Policy.tftpl", {
    sns_topic_arn                = one(aws_sns_topic.us-east-1).arn
    config_iam_service_role_name = var.org_aws_config.service_role.name
    region                       = "us-east-1"
    root_account_id              = local.root_account_id
    org_id                       = local.org_id
  })
}

#---------------------------------------------------------------------
### Config - us-west-1

resource "aws_config_configuration_recorder" "us-west-1" {
  provider = aws.us-west-1

  name     = var.org_aws_config.recorder_name
  role_arn = aws_iam_role.Org_Config_Role.arn

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
  s3_kms_key_arn = "arn:aws:kms:us-west-1:${local.root_account_id}:alias/${var.org_kms_key.alias_name}"
  sns_topic_arn  = "arn:aws:sns:us-west-1:${local.root_account_id}:${var.org_aws_config.sns_topic.name}"

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_channel_snapshot_frequency
  }

  depends_on = [aws_config_configuration_recorder.us-west-1]
}

resource "aws_sns_topic" "us-west-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.us-west-1

  name              = var.org_aws_config.sns_topic.name
  display_name      = var.org_aws_config.sns_topic.display_name
  kms_master_key_id = one(aws_kms_key.Org_KMS_Key).id
  tags              = var.org_aws_config.sns_topic.tags
}

resource "aws_sns_topic_policy" "us-west-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.us-west-1

  arn = one(aws_sns_topic.us-west-1).arn
  policy = templatefile("${path.module}/templates/Config_SNS_Topic_Policy.tftpl", {
    sns_topic_arn                = one(aws_sns_topic.us-west-1).arn
    config_iam_service_role_name = var.org_aws_config.service_role.name
    region                       = "us-west-1"
    root_account_id              = local.root_account_id
    org_id                       = local.org_id
  })
}

#---------------------------------------------------------------------
### Config - us-west-2

resource "aws_config_configuration_recorder" "us-west-2" {
  provider = aws.us-west-2

  name     = var.org_aws_config.recorder_name
  role_arn = aws_iam_role.Org_Config_Role.arn

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
  s3_kms_key_arn = "arn:aws:kms:us-west-2:${local.root_account_id}:alias/${var.org_kms_key.alias_name}"
  sns_topic_arn  = "arn:aws:sns:us-west-2:${local.root_account_id}:${var.org_aws_config.sns_topic.name}"

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_channel_snapshot_frequency
  }

  depends_on = [aws_config_configuration_recorder.us-west-2]
}

resource "aws_sns_topic" "us-west-2" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.us-west-2

  name              = var.org_aws_config.sns_topic.name
  display_name      = var.org_aws_config.sns_topic.display_name
  kms_master_key_id = one(aws_kms_key.Org_KMS_Key).id
  tags              = var.org_aws_config.sns_topic.tags
}

resource "aws_sns_topic_policy" "us-west-2" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.us-west-2

  arn = one(aws_sns_topic.us-west-2).arn
  policy = templatefile("${path.module}/templates/Config_SNS_Topic_Policy.tftpl", {
    sns_topic_arn                = one(aws_sns_topic.us-west-2).arn
    config_iam_service_role_name = var.org_aws_config.service_role.name
    region                       = "us-west-2"
    root_account_id              = local.root_account_id
    org_id                       = local.org_id
  })
}

######################################################################
