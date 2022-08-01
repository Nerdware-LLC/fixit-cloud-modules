######################################################################
### AWS CloudTrail

resource "aws_cloudtrail" "this" {
  name = var.trail_name

  is_organization_trail         = var.is_organization_trail
  is_multi_region_trail         = true
  include_global_service_events = var.include_global_service_events

  # Logging Config
  s3_bucket_name             = var.logging_config.s3_bucket_name
  enable_log_file_validation = true
  # tfsec:ignore:aws-cloudtrail-enable-at-rest-encryption
  kms_key_id = var.logging_config.sse_kms_key_arn
  # As of 12/6/21, the ignored rule above always err's out. Rm the 'ignore' directive once they fix it.

  # CloudTrail requires the Log Stream wildcard as shown below (all streams are allowed)
  cloud_watch_logs_group_arn = "${var.cloud_watch_logs_config.log_group_arn}:*"
  cloud_watch_logs_role_arn  = var.cloud_watch_logs_config.logs_delivery_service_role_arn

  tags = var.trail_tags

  lifecycle {
    /* As of 1/2/22, a constant diff was being shown for an advanced_event_selector
    that AWS auto-generates that seems to be intended to capture MANAGEMENT events,
    even though TFR docs for aws_cloudtrail make it clear that the event selector
    blocks are only for capturing DATA events. Since we don't collect data events
    at this time, they've been ignored to kill the persistent erroneous diff msg. */
    ignore_changes = [event_selector, advanced_event_selector]
  }
}

######################################################################
