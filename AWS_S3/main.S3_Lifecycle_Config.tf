######################################################################
### S3 Bucket Lifecycle Config

resource "aws_s3_bucket_lifecycle_configuration" "list" {
  count = var.lifecycle_rules != null ? 1 : 0

  bucket = aws_s3_bucket.this.id

  # RULE
  dynamic "rule" {
    for_each = {
      for rule_id, rule_config in var.lifecycle_rules : rule_id => rule_config
    }
    content {
      id     = rule.key
      status = coalesce(rule.value.status, "Enabled")

      # RULE.filter
      dynamic "filter" {
        for_each = rule.value.filter != null ? [rule.value.filter] : []
        content {
          prefix                   = filter.value.prefix
          object_size_greater_than = filter.value.object_size_greater_than
          object_size_less_than    = filter.value.object_size_less_than

          # RULE.filter.tag
          dynamic "tag" {
            for_each = filter.value.tag != null ? [filter.value.tag] : []
            content {
              key   = tag.value.key
              value = tag.value.value
            }
          }

          # RULE.filter.and
          dynamic "and" {
            for_each = filter.value.and != null ? [filter.value.and] : []
            content {
              prefix                   = and.value.prefix
              object_size_greater_than = and.value.object_size_greater_than
              object_size_less_than    = and.value.object_size_less_than
              tags                     = and.value.tags
            }
          }
        }
      }

      # RULE.abort_incomplete_multipart_upload
      dynamic "abort_incomplete_multipart_upload" {
        for_each = (
          rule.value.abort_incomplete_multipart_upload != null
          ? [rule.value.abort_incomplete_multipart_upload]
          : []
        )
        iterator = "abort_mpu" # <-- merely to shorten the ref below
        content {
          days_after_initiation = abort_mpu.value.days_after_initiation
        }
      }

      # RULE.transition
      dynamic "transition" {
        for_each = rule.value.transition != null ? [rule.value.transition] : []
        content {
          date          = transition.value.date
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      # RULE.expiration
      dynamic "expiration" {
        for_each = rule.value.expiration != null ? [rule.value.expiration] : []
        content {
          date                         = expiration.value.date
          days                         = expiration.value.days
          expired_object_delete_marker = expiration.value.expired_object_delete_marker
        }
      }

      # RULE.noncurrent_version_transition
      dynamic "noncurrent_version_transition" {
        for_each = (
          rule.value.noncurrent_version_transition != null
          ? [rule.value.noncurrent_version_transition]
          : []
        )
        iterator = "old_v_transition" # <-- merely to shorten the refs below
        content {
          newer_noncurrent_versions = old_v_transition.value.newer_noncurrent_versions
          noncurrent_days           = old_v_transition.value.noncurrent_days
          storage_class             = old_v_transition.value.storage_class
        }
      }

      # RULE.noncurrent_version_expiration
      dynamic "noncurrent_version_expiration" {
        for_each = (
          rule.value.noncurrent_version_expiration != null
          ? [rule.value.noncurrent_version_expiration]
          : []
        )
        iterator = "old_v_expiration" # <-- merely to shorten the refs below
        content {
          newer_noncurrent_versions = old_v_expiration.value.newer_noncurrent_versions
          noncurrent_days           = old_v_expiration.value.noncurrent_days
        }
      }
    }
  }

  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.this]
}

######################################################################
