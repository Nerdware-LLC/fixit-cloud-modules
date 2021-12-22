######################################################################
### Organization Services KMS Key

locals {
  # alias can be used cross-region in lieu of getting region-specific key ID
  org_kms_key_alias = "alias/${var.org_kms_key.alias_name}"

  key_description = coalesce(
    var.org_kms_key.description,
    "A multi-region KMS key to encrypt Log-Archive files and data streams for Org-wide services like CloudTrail, CloudWatch, and SNS."
  )
}

#---------------------------------------------------------------------
### Org Services KMS Key ALIAS

resource "aws_kms_alias" "Org_KMS_Key" {
  count = local.IS_ROOT_ACCOUNT ? 1 : 0

  name          = local.org_kms_key_alias
  target_key_id = one(aws_kms_key.Org_KMS_Key).key_id
}

#---------------------------------------------------------------------
### Org Services KMS Key - us-east-2 (ORIGINAL KEY)

resource "aws_kms_key" "Org_KMS_Key" {
  count = local.IS_ROOT_ACCOUNT ? 1 : 0

  description         = local.key_description
  multi_region        = true
  enable_key_rotation = true
  tags                = var.org_kms_key.tags
  # NOTE: in KMS key policies, all 'resource' values must = "*" (points to the key itself)
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = var.org_kms_key.key_policy_id
    Statement = [
      # KEY POLICIES --> IAM Users/Roles
      {
        Sid       = "EnableAdminIAMUserPermissions"
        Effect    = "Allow"
        Principal = { AWS = [local.root_account_arn, local.log_archive_account_arn] }
        Action    = "kms:*"
        Resource  = "*"
        StringEquals = {
          "aws:PrincipalOrgID" = [local.org_id]
        }
      },
      {
        Sid       = "EnableCrossAccountLogDecryptionAndAliasCreation"
        Effect    = "Allow"
        Principal = { AWS = "*" }
        Action    = ["kms:Decrypt", "kms:ReEncryptFrom", "kms:CreateAlias"]
        Resource  = "*"
        Condition = {
          StringEquals = {
            "kms:CallerAccount" = [local.root_account_arn, local.log_archive_account_arn]
          }
          StringEquals = {
            "aws:PrincipalOrgID" = [local.org_id]
          }
        }
      },
      # KEY POLICIES --> CloudTrail
      {
        Sid       = "AllowCloudTrailEncryptLogsWithKey"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "kms:GenerateDataKey*"
        Resource  = "*"
        Condition = {
          ArnLike = {
            "kms:EncryptionContext:aws:cloudtrail:arn" = ["arn:aws:cloudtrail:*:${local.root_account_id}:trail/*"]
          }
          ArnLike = {
            "aws:SourceArn" = ["arn:aws:cloudtrail:*:${local.root_account_id}:trail/${var.org_cloudtrail.name}"]
          }
        }
      },
      {
        Sid       = "AllowCloudTrailDescribeKey"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "kms:DescribeKey"
        Resource  = "*"
      },
      # KEY POLICIES --> AWS-Config
      {
        Sid       = "AWSConfigKMSPolicy"
        Effect    = "Allow"
        Principal = { AWS = local.config_iam_role_arn } # NOT the service, since we have Config assume an IAM role.
        Action    = ["kms:Decrypt", "kms:GenerateDataKey*"]
        Resource  = "*"
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
### REGIONAL REPLICA KEYS:
#---------------------------------------------------------------------
# Org_KMS_Key Replica - ap-northeast-1

resource "aws_kms_replica_key" "ap-northeast-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.ap-northeast-1

  primary_key_arn         = one(aws_kms_key.Org_KMS_Key).arn
  description             = local.key_description
  deletion_window_in_days = 7
}

#---------------------------------------------------------------------
# Org_KMS_Key Replica - ap-northeast-2

resource "aws_kms_replica_key" "ap-northeast-2" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.ap-northeast-2

  primary_key_arn         = one(aws_kms_key.Org_KMS_Key).arn
  description             = local.key_description
  deletion_window_in_days = 7
}

#---------------------------------------------------------------------
# Org_KMS_Key Replica - ap-northeast-3

resource "aws_kms_replica_key" "ap-northeast-3" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.ap-northeast-3

  primary_key_arn         = one(aws_kms_key.Org_KMS_Key).arn
  description             = local.key_description
  deletion_window_in_days = 7
}

#---------------------------------------------------------------------
# Org_KMS_Key Replica - ap-south-1

resource "aws_kms_replica_key" "ap-south-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.ap-south-1

  primary_key_arn         = one(aws_kms_key.Org_KMS_Key).arn
  description             = local.key_description
  deletion_window_in_days = 7
}

#---------------------------------------------------------------------
# Org_KMS_Key Replica - ap-southeast-1

resource "aws_kms_replica_key" "ap-southeast-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.ap-southeast-1

  primary_key_arn         = one(aws_kms_key.Org_KMS_Key).arn
  description             = local.key_description
  deletion_window_in_days = 7
}

#---------------------------------------------------------------------
# Org_KMS_Key Replica - ap-southeast-2

resource "aws_kms_replica_key" "ap-southeast-2" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.ap-southeast-2

  primary_key_arn         = one(aws_kms_key.Org_KMS_Key).arn
  description             = local.key_description
  deletion_window_in_days = 7
}

#---------------------------------------------------------------------
# Org_KMS_Key Replica - ca-central-1

resource "aws_kms_replica_key" "ca-central-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.ca-central-1

  primary_key_arn         = one(aws_kms_key.Org_KMS_Key).arn
  description             = local.key_description
  deletion_window_in_days = 7
}

#---------------------------------------------------------------------
# Org_KMS_Key Replica - eu-north-1

resource "aws_kms_replica_key" "eu-north-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.eu-north-1

  primary_key_arn         = one(aws_kms_key.Org_KMS_Key).arn
  description             = local.key_description
  deletion_window_in_days = 7
}

#---------------------------------------------------------------------
# Org_KMS_Key Replica - eu-central-1

resource "aws_kms_replica_key" "eu-central-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.eu-central-1

  primary_key_arn         = one(aws_kms_key.Org_KMS_Key).arn
  description             = local.key_description
  deletion_window_in_days = 7
}

#---------------------------------------------------------------------
# Org_KMS_Key Replica - eu-west-1

resource "aws_kms_replica_key" "eu-west-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.eu-west-1

  primary_key_arn         = one(aws_kms_key.Org_KMS_Key).arn
  description             = local.key_description
  deletion_window_in_days = 7
}

#---------------------------------------------------------------------
# Org_KMS_Key Replica - eu-west-2

resource "aws_kms_replica_key" "eu-west-2" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.eu-west-2

  primary_key_arn         = one(aws_kms_key.Org_KMS_Key).arn
  description             = local.key_description
  deletion_window_in_days = 7
}

#---------------------------------------------------------------------
# Org_KMS_Key Replica - eu-west-3

resource "aws_kms_replica_key" "eu-west-3" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.eu-west-3

  primary_key_arn         = one(aws_kms_key.Org_KMS_Key).arn
  description             = local.key_description
  deletion_window_in_days = 7
}

#---------------------------------------------------------------------
# Org_KMS_Key Replica - sa-east-1

resource "aws_kms_replica_key" "sa-east-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.sa-east-1

  primary_key_arn         = one(aws_kms_key.Org_KMS_Key).arn
  description             = local.key_description
  deletion_window_in_days = 7
}

#---------------------------------------------------------------------
# Org_KMS_Key Replica - us-east-1

resource "aws_kms_replica_key" "us-east-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.us-east-1

  primary_key_arn         = one(aws_kms_key.Org_KMS_Key).arn
  description             = local.key_description
  deletion_window_in_days = 7
}

#---------------------------------------------------------------------
# Org_KMS_Key Replica - us-west-1

resource "aws_kms_replica_key" "us-west-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.us-west-1

  primary_key_arn         = one(aws_kms_key.Org_KMS_Key).arn
  description             = local.key_description
  deletion_window_in_days = 7
}

#---------------------------------------------------------------------
# Org_KMS_Key Replica - us-west-2

resource "aws_kms_replica_key" "us-west-2" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.us-west-2

  primary_key_arn         = one(aws_kms_key.Org_KMS_Key).arn
  description             = local.key_description
  deletion_window_in_days = 7
}

######################################################################
