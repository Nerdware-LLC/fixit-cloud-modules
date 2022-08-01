######################################################################
### INPUT VARIABLES

variable "trail_name" {
  description = "The name of the CloudTrail trail."
  type        = string
}

variable "is_organization_trail" {
  description = <<-EOF
  Boolean indicator as to whether the CloudTrail trail is
  an organization trail (default: false).
  EOF

  type    = bool
  default = false
}

variable "include_global_service_events" {
  description = <<-EOF
  Boolean indicator as to whether the CloudTrail trail should
  include global service events (default: false).
  EOF

  type    = bool
  default = false
}

variable "logging_config" {
  description = <<-EOF
  Logging config object for the CloudTrail trail. If the S3 Bucket
  uses a KMS Key for SSE, provide the ARN to "sse_kms_key_arn".
  EOF

  type = object({
    s3_bucket_name  = string
    sse_kms_key_arn = optional(string)
  })
}

variable "cloud_watch_logs_config" {
  description = <<-EOF
  Config object for delivery of CloudTrail log files to a
  CloudWatch Logs log group.
  EOF

  type = object({
    log_group_arn                  = string
    logs_delivery_service_role_arn = string
  })
}

variable "trail_tags" {
  description = "Tags for the CloudTrail trail."
  type        = map(string)
  default     = null
}

######################################################################
