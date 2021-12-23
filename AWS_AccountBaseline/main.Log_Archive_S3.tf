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
    enabled    = true
    mfa_delete = true
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
      # S3 BUCKET POLICY --> CloudTrail
      {
        Sid       = "OnlyAllowOrgServicesAclCheck"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:GetBucketAcl"
        Resource  = aws_s3_bucket.list[1].arn
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
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.list[1].arn}/*"
        Condition = {
          StringEquals = {
            "aws:SourceArn" = "arn:aws:cloudtrail:${local.aws_region}:${var.log_archive_account_id}:trail/${var.org_cloudtrail.name}"
          }
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      },
      # S3 BUCKET POLICY --> Config
      {
        Sid    = "AWSConfigCheckBucketExistenceAndPerms"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${local.root_account_id}:role/${var.org_aws_config.service_role.name}"
        }
        Action   = ["s3:ListBucket", "s3:GetBucketAcl"]
        Resource = aws_s3_bucket.list[1].arn
        Condition = {
          StringEquals = {
            "aws:PrincipalOrgID" = local.org_id
          }
        }
      },
      {
        Sid    = "AWSConfigWrite"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${local.root_account_id}:role/${var.org_aws_config.service_role.name}"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.list[1].arn}/*"
        Condition = {
          StringEquals = {
            "aws:PrincipalOrgID" = local.org_id
          }
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
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
        Sid       = "OnlyAllowWritesFromOrgLogArchiveS3"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource  = [aws_s3_bucket.list[0].arn, "${aws_s3_bucket.list[0].arn}/*"]
        Condition = {
          Bool = { "aws:SecureTransport" = "false" }
        }
      }
    ]
  }
}

######################################################################
