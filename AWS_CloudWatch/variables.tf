######################################################################
### INPUT VARIABLES

variable "cloudwatch_logs_log_groups" {
  description = <<-EOF
  Map of CloudWatch Logs log group names to config objects. If not
  provided, "retention_in_days" defaults to 400.
  EOF

  type = map(
    # map keys: log group names
    object({
      retention_in_days = optional(number)
      kms_key_arn       = optional(string)
      tags              = optional(map(string))
    })
  )
}

variable "cloudwatch_metrics" {
  description = <<-EOF
  Map of CloudWatch metric names to config objects. For both "alarm" and
  "log_metric_filter", if "name" is not specified, the metric name will
  be used instead.

  Within "metric_transformations", if neither "default_value" nor
  "dimensions" are provided, "default_value" will be set to "0".

  EOF

  type = map(
    # map keys: metric names
    object({
      namespace = string
      log_metric_filter = object({
        name           = optional(string)
        pattern        = string
        log_group_name = string
        metric_transformation = object({
          name          = string
          value         = string
          default_value = optional(string)
          dimensions    = optional(string)
          unit          = optional(string)
        })
      })
      alarm = object({
        name        = optional(string)
        description = optional(string)
        tags        = optional(map(string))
      })
    })
  )
}

######################################################################
