######################################################################
### AWS Lambda - Event Source Mapping

resource "aws_lambda_event_source_mapping" "list" {
  count = var.event_source_mapping != null ? 1 : 0

  function_name    = aws_lambda_function.this.arn
  event_source_arn = var.event_source_mapping.event_source_arn
  enabled          = var.event_source_mapping.enabled
  queues           = var.event_source_mapping.queues != null ? [var.event_source_mapping.queues] : null

  batch_size                         = var.event_source_mapping.batch_size
  maximum_batching_window_in_seconds = var.event_source_mapping.maximum_batching_window_in_seconds
  maximum_record_age_in_seconds      = var.event_source_mapping.maximum_record_age_in_seconds
  maximum_retry_attempts             = var.event_source_mapping.maximum_retry_attempts

  starting_position           = var.event_source_mapping.starting_position
  starting_position_timestamp = var.event_source_mapping.starting_position_timestamp # RFC3339 timestamp

  # FILTERS
  dynamic "filter_criteria" {
    for_each = toset(
      var.event_source_mapping.filter_patterns != null
      ? var.event_source_mapping.filter_patterns # <-- list var
      : []
    )

    content {
      filter {
        pattern = filter_criteria.value
      }
    }
  }

  # DESTINATIONS (onSuccess, onFailure)
  dynamic "destination_config" {
    for_each = (
      var.event_source_mapping.destination_config != null
      ? [var.event_source_mapping.destination_config]
      : []
    )

    content {
      dynamic "on_failure" {
        for_each = (
          destination_config.value.on_failure_dest_resource_arn != null
          ? [destination_config.value.on_failure_dest_resource_arn]
          : []
        )

        content {
          destination_arn = destination_config.value.on_failure_dest_resource_arn
        }
      }
    }
  }
}

######################################################################
