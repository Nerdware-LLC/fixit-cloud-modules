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
    ? one(data.aws_iam_policy_document.Access_Logs_S3_Bucket_Policy).json
    : one(data.aws_iam_policy_document.Org_Log_Archive_S3_Bucket_Policy).json
  )
}

data "aws_iam_policy_document" "Org_Log_Archive_S3_Bucket_Policy" {
  count = local.IS_LOG_ARCHIVE_ACCOUNT ? 1 : 0

  policy_id = "Org_Log_Archive_S3_Bucket_Policy"
  version   = "2012-10-17"

  statement {
    sid    = "OnlyAllowOrgServicesAclCheck"
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "cloudtrail.amazonaws.com",
        "config.amazonaws.com"
      ]
    }
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.list[0].arn]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"
      values   = [local.root_account_id]
    }
  }

  statement {
    sid    = "AWSConfigBucketExistenceCheck"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.list[0].arn]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"
      values   = [local.root_account_id]
    }
  }

  statement {
    sid    = "AllowOrgCloudTrailWrite"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.list[0].arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:aws:cloudtrail:${local.aws_region}:${local.root_account_id}:trail/${var.org_cloudtrail.name}"]
    }
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  statement {
    sid    = "AllowOrgConfigServiceWrite"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.list[0].arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.root_account_id]
    }
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

data "aws_iam_policy_document" "Access_Logs_S3_Bucket_Policy" {
  count = local.IS_LOG_ARCHIVE_ACCOUNT ? 1 : 0

  policy_id = "Org_Log_Archive_S3_Access_Logs_Bucket_Policy"
  version   = "2012-10-17"

  statement {
    sid    = "OnlyAllowWritesFromOrgLogArchiveS3"
    effect = "Deny"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = ["s3:*"]
    resources = [
      aws_s3_bucket.list[0].arn,
      "${aws_s3_bucket.list[0].arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = [tobool(false)]
    }
  }
}

######################################################################
