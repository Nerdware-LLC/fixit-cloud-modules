######################################################################
### Org CloudTrail S3 Buckets

/* We need two S3 buckets to store CloudTrail/CloudWatch logs:
    1) A bucket to store CloudTrail event stream logs
    2) A bucket to store access logs from the first bucket
*/

locals {
  cloudtrail_s3_configs = [
    {
      bucket_name           = var.org_cloudtrail_s3_bucket.access_logs_s3.name
      enable_access_logging = false
      tags                  = var.org_cloudtrail_s3_bucket.access_logs_s3.tags
    },
    {
      bucket_name           = var.org_cloudtrail_s3_bucket.name
      enable_access_logging = true
      tags                  = var.org_cloudtrail_s3_bucket.tags
    }
  ]
}

# Ignored bc we don't need access logs for our access logs S3
#tfsec:ignore:aws-s3-enable-bucket-logging
resource "aws_s3_bucket" "Org_CloudTrail_S3_Buckets" {
  count = local.IS_LOG_ARCHIVE_ACCOUNT ? 2 : 0

  bucket = local.cloudtrail_s3_configs[count.index].bucket_name
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

  dynamic "logging" {
    for_each = (local.cloudtrail_s3_configs[count.index].enable_access_logging == true
      ? { target_bucket = var.org_cloudtrail_s3_bucket.access_logs_s3.name }
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

  tags = local.cloudtrail_s3_configs[count.index].tags
}

#---------------------------------------------------------------------
### S3 Bucket Public Access Blocks:

resource "aws_s3_bucket_public_access_block" "Org_CloudTrail_S3_Buckets" {
  count = local.IS_LOG_ARCHIVE_ACCOUNT ? 2 : 0

  bucket = aws_s3_bucket.Org_CloudTrail_S3_Buckets[count.index].id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

#---------------------------------------------------------------------
### S3 Bucket Policies:

resource "aws_s3_bucket_policy" "Org_CloudTrail_S3_Bucket" {
  count = local.IS_LOG_ARCHIVE_ACCOUNT ? 2 : 0

  bucket = aws_s3_bucket.Org_CloudTrail_S3_Buckets[count.index].id

  # index 0 = access_logs_s3    index 1 = Org_CloudTrail logs
  policy = (count.index == 0
    ? jsonencode({
      Version = "2012-10-17"
      Id      = "Org_CloudTrail_S3_Access_Logs_Bucket_Policy"
      Statement = [
        {
          Sid       = "OnlyAllowWritesFromOrgCloudTrailS3"
          Effect    = "Deny"
          Principal = "*"
          Action    = "s3:*"
          Resource = [
            aws_s3_bucket.Org_CloudTrail_S3_Buckets[count.index].arn,
            "${aws_s3_bucket.Org_CloudTrail_S3_Buckets[count.index].arn}/*"
          ]
          Condition = { Bool = { "aws:SecureTransport" = false } }
        }
      ]
    })
    : jsonencode({
      Version = "2012-10-17"
      Id      = "Org_CloudTrail_S3_Bucket_Policy"
      Statement = [
        {
          Sid       = "OnlyAllowOrgCloudTrailAclCheck"
          Effect    = "Allow"
          Principal = { Service = "cloudtrail.amazonaws.com" }
          Action    = "s3:GetBucketAcl"
          Resource  = aws_s3_bucket.Org_CloudTrail_S3_Buckets[count.index].arn
        },
        {
          Sid       = "OnlyAllowOrgCloudTrailWrite"
          Effect    = "Allow"
          Principal = { Service = "cloudtrail.amazonaws.com" }
          Action    = "s3:PutObject",
          Resource  = aws_s3_bucket.Org_CloudTrail_S3_Buckets[count.index].arn,
          Condition = {
            StringEquals = {
              "aws:SourceArn" = aws_s3_bucket.Org_CloudTrail_S3_Buckets[count.index].arn
              "s3:x-amz-acl"  = "bucket-owner-full-control"
            }
          }
        }
      ]
    })
  )
}

######################################################################
