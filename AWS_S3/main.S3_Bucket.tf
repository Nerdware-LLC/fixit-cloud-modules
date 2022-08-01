######################################################################
### S3 Bucket

/* tfsec rule ignored bc access logging is handled via the
aws_s3_bucket_logging resource, which tfsec is not recognizing. */

# tfsec:ignore:aws-s3-enable-bucket-logging
resource "aws_s3_bucket" "this" {
  bucket              = var.bucket_name
  object_lock_enabled = true # no reason to not have this enabled
  tags                = var.bucket_tags
}

#---------------------------------------------------------------------
### S3 Bucket Versioning

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  mfa = (
    var.mfa_delete_config != null
    ? "${var.mfa_delete_config.auth_device_serial_number} ${var.mfa_delete_config.auth_device_code_value}"
    : null
  )

  versioning_configuration {
    status     = "Enabled"
    mfa_delete = var.mfa_delete_config != null ? "Enabled" : "Disabled"
  }
}

#---------------------------------------------------------------------
### S3 Bucket Server Side Encryption

# tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    bucket_key_enabled = lookup(var.sse_kms_config, "should_enable_bucket_key", false)

    # If user provided a KMS key, use SSE-KMS, else SSE-S3.
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.sse_kms_config != null ? "aws:kms" : "AES256"
      kms_master_key_id = lookup(var.sse_kms_config, "key_arn", null)
    }
  }
}

#---------------------------------------------------------------------
### S3 Object Lock - Bucket Default Retention

resource "aws_s3_bucket_object_lock_configuration" "map" {
  for_each = var.object_lock_default_retention != null ? [var.bucket_name] : []

  bucket = aws_s3_bucket.this.bucket

  rule {
    default_retention {
      mode  = var.object_lock_default_retention.mode
      days  = var.object_lock_default_retention.days
      years = var.object_lock_default_retention.years
    }
  }
}

#---------------------------------------------------------------------
### S3 Bucket Access Logging

resource "aws_s3_bucket_logging" "map" {
  for_each = var.access_logs_config != null ? [var.bucket_name] : []
  /* access_logs_config will be null only if "aws_s3_bucket.this" will
  itself be an access-logs bucket that will receive access logs from
  other buckets. */

  bucket = aws_s3_bucket.this.id

  target_bucket = var.access_logs_config.bucket_name
  target_prefix = coalesce(
    var.access_logs_config.access_logs_prefix,
    var.bucket_name
  )
}

#---------------------------------------------------------------------
### S3 Bucket - Transfer Acceleration

resource "aws_s3_bucket_accelerate_configuration" "map" {
  for_each = var.transfer_acceleration != null ? [var.bucket_name] : []

  bucket = aws_s3_bucket.this.bucket
  status = var.transfer_acceleration # "Enabled" or "Suspended"
}

######################################################################
