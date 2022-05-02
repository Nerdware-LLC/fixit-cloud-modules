######################################################################
### S3 Bucket Replication Config

resource "aws_s3_bucket_replication_configuration" "list" {
  count = var.replication_config != null ? 1 : 0

  # The SOURCE bucket
  bucket = aws_s3_bucket.this.id
  role   = var.replication_config.s3_replication_service_role_arn

  # RULE
  dynamic "rule" {
    for_each = var.replication_config.rules
    content {
      id       = rule.key
      priority = rule.value.priority # status default: Enabled
      status   = rule.value.is_enabled != false ? "Enabled" : "Disabled"

      # RULE.delete_marker_replication
      delete_marker_replication {
        status = ( # default: Enabled
          rule.value.should_replicate_delete_markers != false
          ? "Enabled"
          : "Disabled"
        )
      }

      # RULE.existing_object_replication
      existing_object_replication {
        status = ( # default: Enabled
          rule.value.should_replicate_existing_objects != false
          ? "Enabled"
          : "Disabled"
        )
      }

      # RULE.source_selection_criteria
      dynamic "source_selection_criteria" {
        for_each = (
          rule.value.should_replicate_encrypted_objects != false
          ? ["Enabled"]
          : []
        )
        content {
          replica_modifications {
            status = source_selection_criteria.value
          }
          sse_kms_encrypted_objects {
            status = source_selection_criteria.value
          }
        }
      }

      # RULE.filter
      dynamic "filter" {
        for_each = rule.value.filter != null ? [rule.value.filter] : []
        content {
          prefix = filter.value.prefix

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
              prefix = and.value.prefix
              tags   = and.value.tags
            }
          }
        }
      }

      # RULE.destination
      destination {
        account       = rule.value.destination.account
        bucket        = rule.value.destination.bucket_arn
        storage_class = rule.value.destination.storage_class

        # RULE.destination.access_control_translation
        dynamic "access_control_translation" {
          for_each = ( # default: Dest becomes owner
            rule.value.destination.should_destination_become_owner != false
            ? [{ owner = "Destination" }]
            : []
          )
          content {
            owner = access_control_translation.value.owner
          }
        }

        # RULE.destination.encryption_config
        dynamic "encryption_config" {
          for_each = (
            rule.value.destination.replica_kms_key_arn != null
            ? [rule.value.destination.replica_kms_key_arn]
            : []
          )
          content {
            replica_kms_key_id = encryption_config.value
          }
        }

        # RULE.destination.metrics
        metrics {
          status = (
            rule.value.destination.should_enable_metrics != false
            ? "Enabled"
            : "Disabled"
          )

          # RULE.destination.metrics.event_threshold
          dynamic "event_threshold" {
            for_each = ( # default: no event_threshold (no S3 Event Notifications onFail)
              coalesce(metrics.value.should_replication_complete_within_15_minutes, false)
              ? [{ minutes = 15 }] # 15 is the only valid value
              : []
            )
            content {
              minutes = event_threshold.value.minutes
            }
          }
        }

        # RULE.destination.replication_time
        dynamic "replication_time" {
          for_each = ( # replication_time must be set if metrics are enabled
            rule.value.destination.should_enable_metrics != false
            ? [{ minutes = 15 }] # 15 is the only valid value
            : []
          )
          content {
            status = "Enabled"
            time {
              minutes = replication_time.value.minutes
            }
          }
        }
      }
    }
  }

  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.this]
}

######################################################################
