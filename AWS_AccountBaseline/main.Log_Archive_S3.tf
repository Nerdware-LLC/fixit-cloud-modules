######################################################################
### Org Log Archive S3 Buckets

/* We need two S3 buckets to store logs for the Organization:
    1) A bucket to store logs from CloudTrail, CloudWatch, and Config.
    2) A bucket to store access logs from the first bucket.
*/

locals {
  log_archive_s3_configs = [
    {
      bucket_name           = var.org_log_archive_s3_bucket.access_logs_s3.name
      enable_access_logging = false
      tags                  = var.org_log_archive_s3_bucket.access_logs_s3.tags
    },
    {
      bucket_name           = var.org_log_archive_s3_bucket.name
      enable_access_logging = true
      tags                  = var.org_log_archive_s3_bucket.tags
    }
  ]
}

# Ignored bc we don't need access logs for our access logs S3
#tfsec:ignore:aws-s3-enable-bucket-logging
resource "aws_s3_bucket" "list" {
  count = local.IS_LOG_ARCHIVE_ACCOUNT ? 2 : 0

  bucket = local.log_archive_s3_configs[count.index].bucket_name
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      bucket_key_enabled = true
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  dynamic "logging" {
    for_each = (local.log_archive_s3_configs[count.index].enable_access_logging == true
      ? { target_bucket = var.org_log_archive_s3_bucket.access_logs_s3.name }
      : {}
    )
    content {
      target_bucket = logging.value
    }
  }

  lifecycle_rule {
    id      = "auto-archive"
    enabled = true

    transition {
      days          = 30
      storage_class = "GLACIER"
    }
  }

  tags = local.log_archive_s3_configs[count.index].tags
}

#---------------------------------------------------------------------
### S3 Bucket Public Access Blocks:

resource "aws_s3_bucket_public_access_block" "list" {
  count = local.IS_LOG_ARCHIVE_ACCOUNT ? 2 : 0

  bucket = aws_s3_bucket.list[count.index].id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

#---------------------------------------------------------------------
### S3 Bucket Policies:

resource "aws_s3_bucket_policy" "list" {
  count = local.IS_LOG_ARCHIVE_ACCOUNT ? 2 : 0

  bucket = aws_s3_bucket.list[count.index].id

  # index 0 = access_logs_s3    index 1 = Org_Log_Archive logs
  policy = (count.index == 0
    ? jsonencode(local.Access_Logs_S3_Bucket_Policy)
    : jsonencode(local.Org_Log_Archive_S3_Bucket_Policy)
  )
}

locals {
  Org_Log_Archive_S3_Bucket_Policy = {
    Id      = "Org_Log_Archive_S3_Bucket_Policy"
    Version = "2012-10-17"
    Statement = [
      # S3 BUCKET POLICY --> IAM Users/Roles
      {
        Sid       = "AllowOrgPrincipalsUsage"
        Effect    = "Allow"
        Principal = { AWS = "*" }
        Action    = "s3:*"
        Resource = [
          "arn:aws:s3:::${var.org_log_archive_s3_bucket.name}",
          "arn:aws:s3:::${var.org_log_archive_s3_bucket.name}/*"
        ]
        Condition = {
          StringEquals = {
            "aws:PrincipalOrgID" = local.org_id
          }
        }
      },
      # S3 BUCKET POLICY --> CloudTrail
      {
        Sid       = "OnlyAllowOrgServicesAclCheck"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:GetBucketAcl"
        Resource  = "arn:aws:s3:::${var.org_log_archive_s3_bucket.name}"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = local.root_account_id
          }
        }
      },
      {
        Sid       = "AllowOrgCloudTrailWrite"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        Resource = "arn:aws:s3:::${var.org_log_archive_s3_bucket.name}/*"
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = "arn:aws:cloudtrail:${local.aws_region}:${local.root_account_id}:trail/${var.org_cloudtrail.name}"
          }
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      },
      # S3 BUCKET POLICY --> Config SERVICE (the ROLE should be covered by the first statement for Org IAM)
      {
        Sid       = "AWSConfigBucketExistenceAndPermsCheck"
        Effect    = "Allow"
        Principal = { Service = "config.amazonaws.com" }
        Action = [
          "s3:ListBucket",
          "s3:GetBucketAcl"
        ]
        Resource = "arn:aws:s3:::${var.org_log_archive_s3_bucket.name}"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = var.all_account_ids
          }
        }
      },
      {
        Sid       = "AWSConfigBucketDelivery"
        Effect    = "Allow"
        Principal = { Service = "config.amazonaws.com" }
        Action    = ["s3:PutObject", "s3:PutObjectAcl"]
        Resource  = "arn:aws:s3:::${var.org_log_archive_s3_bucket.name}/*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = var.all_account_ids
            "s3:x-amz-acl"      = "bucket-owner-full-control"
          }
        }
      }
    ]
  }

  Access_Logs_S3_Bucket_Policy = {
    Id      = "Org_Log_Archive_S3_Access_Logs_Bucket_Policy"
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "S3ServerAccessLogsPolicy"
        Effect    = "Allow"
        Principal = { Service = "logging.s3.amazonaws.com" }
        Action    = "s3:PutObject"
        Resource  = "arn:aws:s3:::${var.org_log_archive_s3_bucket.access_logs_s3.name}/*"
        Condition = {
          ArnLike = {
            "aws:SourceArn" = "arn:aws:s3:::${var.org_log_archive_s3_bucket.name}"
          }
          StringEquals = {
            "aws:SourceAccount" = var.all_account_ids
          }
        }
      }
    ]
  }
}

######################################################################
