######################################################################
### INPUT VARIABLES
######################################################################
### CloudWatch Logs - Log Groups

variable "cloudwatch_logs_log_groups" {
  description = <<-EOF
  Map of CloudWatch Logs log group names to config objects. If not
  provided, "retention_in_days" defaults to 400. To configure a log
  group's logs to never expire, provide 0.
  EOF

  type = map(
    # map keys: log group names
    object({
      retention_in_days = optional(number)
      kms_key_arn       = optional(string)
      tags              = optional(map(string))
    })
  )
  default = {}
}

#---------------------------------------------------------------------
### CloudWatch Logs - Log Metric Filters

variable "cloudwatch_log_metric_filters" {
  description = <<-EOF
  Map of CloudWatch log metric filter names to config objects.

  Within "metric_transformations", if neither "default_value" nor
  "dimensions" are provided, "default_value" will be set to "0".
  EOF

  type = map(
    # map keys: CloudWatch log metric filter names
    object({
      namespace      = string
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
  )
  default = {}
}

#---------------------------------------------------------------------
### CloudWatch Alarms

variable "cloudwatch_metric_alarms" {
  description = <<-EOF
  Map of CloudWatch metric alarm names to config objects.
  EOF

  type = map(
    # map keys: CloudWatch metric alarm names
    object({
      description = optional(string)
      tags        = optional(map(string))
    })
  )
  default = {}
}

#---------------------------------------------------------------------
### CloudWatch Dashboards

variable "cloudwatch_dashboards" {
  description = "Map of CloudWatch Dashboard names to JSON-encoded dashboard definitions."
  type        = map(string)
  default     = {}
}

######################################################################
