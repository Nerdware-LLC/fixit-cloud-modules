######################################################################
### CloudTrail

resource "aws_cloudtrail" "Org_CloudTrail" {
  count = local.IS_ROOT_ACCOUNT ? 1 : 0

  name = var.org_cloudtrail.name

  is_organization_trail         = true
  include_global_service_events = true # global services like IAM
  is_multi_region_trail         = true

  # Logging Config
  s3_bucket_name = var.org_cloudtrail_s3_bucket.name
  # TODO rm below after debug, keep getting false positive atm
  #tfsec:ignore:aws-cloudtrail-enable-at-rest-encryption
  kms_key_id                 = one(aws_kms_key.Org_CloudTrail_KMS_Key).key_id
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
### Org CloudTrail KMS Key

resource "aws_kms_key" "Org_CloudTrail_KMS_Key" {
  count = local.IS_ROOT_ACCOUNT ? 1 : 0

  description         = "A KMS key to encrypt Org_CloudTrail events."
  policy              = data.aws_iam_policy_document.Org_CloudTrail_KMS_Key.json
  enable_key_rotation = true
  tags = {
    Name = "Org_CloudTrail_KMS_Key"
  }
}

data "aws_iam_policy_document" "Org_CloudTrail_KMS_Key" {
  policy_id = "Key policy created for Org_CloudTrail_KMS_Key"

  statement {
    sid = "Enable IAM User Permissions"

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${var.account_params.id}:root"
      ]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid = "Allow CloudTrail to encrypt logs"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["kms:GenerateDataKey*"]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:aws:cloudtrail:*:${var.account_params.id}:trail/*"]
    }
  }

  statement {
    sid = "Allow CloudTrail to describe key"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["kms:DescribeKey"]
    resources = ["*"]
  }

  statement {
    sid = "Allow principals in the account to decrypt log files"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "kms:Decrypt",
      "kms:ReEncryptFrom"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [var.account_params.id]
    }
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:aws:cloudtrail:*:${var.account_params.id}:trail/*"]
    }
  }

  statement {
    sid = "Allow alias creation during setup"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["kms:CreateAlias"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["ec2.${local.aws_region}.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [var.account_params.id]
    }
  }

  statement {
    sid = "Enable cross account log decryption"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "kms:Decrypt",
      "kms:ReEncryptFrom"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [var.account_params.id]
    }
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:aws:cloudtrail:*:${var.account_params.id}:trail/*"]
    }
  }

  # https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-permissions-for-sns-notifications.html
  statement {
    sid = "Allow CloudTrail to send notifications to the encrypted SNS topic"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions = [
      "kms:GenerateDataKey*",
      "kms:Decrypt"
    ]
    resources = ["*"]
  }
}

#---------------------------------------------------------------------
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
  # This local simply helps to shorten long lines in the below policy doc
  log_grp_stream_arn = [
    "arn:aws:logs:${local.aws_region}:${var.account_params.id}:log-group:${local.cw_log_grp.name}:log-stream:*"
  ]
}

# Used by the CloudTrail-CloudWatch-Delivery_Policy IAM Service Role
data "aws_iam_policy_document" "CloudTrail-CloudWatch-Delivery_Policy" {
  statement {
    sid       = "AWSCloudTrailCreateLogStream"
    actions   = ["logs:CreateLogStream"]
    resources = local.log_grp_stream_arn
  }

  statement {
    sid       = "AWSCloudTrailPutLogEvents"
    actions   = ["logs:PutLogEvents"]
    resources = local.log_grp_stream_arn
  }
}

#---------------------------------------------------------------------
### Org CloudTrail --> S3

resource "aws_s3_bucket" "Org_CloudTrail_S3_Bucket" {
  count = local.IS_LOG_ARCHIVE_ACCOUNT ? 1 : 0

  bucket = var.org_cloudtrail_s3_bucket.name
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  logging {
    target_bucket = "" # FIXME where to send logs for this s3
  }

  lifecycle_rule {
    id      = "auto-archive"
    enabled = true

    transition {
      days          = 30
      storage_class = "GLACIER"
    }
  }

  tags = var.org_cloudtrail_s3_bucket.tags
}

resource "aws_s3_bucket_public_access_block" "Org_CloudTrail_S3_Bucket" {
  count = local.IS_LOG_ARCHIVE_ACCOUNT ? 1 : 0

  bucket = one(aws_s3_bucket.Org_CloudTrail_S3_Bucket).id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

# BEST PRACTICES: attach a resource policy to the bucket, only allow the Org_CloudTrail ARN
resource "aws_s3_bucket_policy" "Org_CloudTrail_S3_Bucket" {
  count = local.IS_LOG_ARCHIVE_ACCOUNT ? 1 : 0

  bucket = one(aws_s3_bucket.Org_CloudTrail_S3_Bucket).id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "Org_CloudTrail_S3_Bucket_Policy"
    Statement = [
      {
        Sid       = "OnlyAllowOrgCloudTrailAclCheck"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:GetBucketAcl"
        Resource  = one(aws_s3_bucket.Org_CloudTrail_S3_Bucket).arn
      },
      {
        Sid       = "OnlyAllowOrgCloudTrailWrite"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:PutObject",
        Resource  = "${one(aws_s3_bucket.Org_CloudTrail_S3_Bucket).arn}/Org_CloudTrail/*",
        Condition = {
          StringEquals = {
            "aws:SourceArn" = one(aws_cloudtrail.Org_CloudTrail).arn
            "s3:x-amz-acl"  = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

######################################################################
