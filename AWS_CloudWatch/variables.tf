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
  Map of CloudWatch log metric filter names to config objects. Within
  "metric_transformation", if neither "default_value" nor "dimensions"
  are provided, "default_value" will be set to "0". "dimensions" can
  at most contain three key-value pairs.
  EOF

  type = map(
    # map keys: CloudWatch log metric filter names
    object({
      log_group_name = string
      pattern        = string
      metric_transformation = object({
        namespace     = string
        name          = string
        value         = string
        default_value = optional(string)
        dimensions    = optional(map(string))
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
  Map of CloudWatch metric alarm names to config objects. "comparison_operator" can
  be "GreaterThanOrEqualToThreshold", "GreaterThanThreshold", "LessThanThreshold", or
  "LessThanOrEqualToThreshold". Additionally, the values "GreaterThanUpperThreshold",
  "LessThanLowerThreshold", and "LessThanLowerOrGreaterThanUpperThreshold" can be used
  for alarms based on anomaly detection models.

  For alarms based on a single static metric in the same account which don't involve
  metric math expressions nor anomaly detection models, use the "static_metric" property.
  For alarms which involve any of those features, use "metric_queries" to map query ID/
  short names to query config objects (max 20). For "metric_queries", at least 1 query
  must have "return_data" and "use_query_to_set_threshold" set to true. For both types,
  "statistic" must be one of "SampleCount", "Average", "Sum", "Minimum", or "Maximum".

  "treat_missing_data" must be one of "ignore", "breaching", "notBreaching", or "missing"
  (default). "actions_enabled" defaults to "true" if not provided.
  EOF

  type = map(
    # map keys: CloudWatch metric alarm names
    object({
      description = optional(string)
      tags        = optional(map(string))
      static_metric = optional(object({
        namespace  = string
        name       = string
        statistic  = string
        period     = number
        unit       = optional(string)
        dimensions = optional(map(string))
        threshold  = string
      }))
      metric_queries = optional(map(
        # map keys: metric query ID/short name
        object({
          account_id           = optional(string)
          expression           = optional(string)
          label                = optional(string)
          return_data          = optional(bool) # Default: false
          use_to_set_threshold = optional(bool) # Default: false
          metric = optional(object({
            namespace  = string
            name       = string
            statistic  = string
            period     = number
            unit       = optional(string)
            dimensions = optional(map(string))
          }))
        })
      ))
      # Threshold evaluation properties:
      comparison_operator = string
      evaluation_periods  = string
      datapoints_to_alarm = optional(number)
      treat_missing_data  = optional(string)
      # Action properties:
      actions_enabled               = optional(bool) # Default: true
      alarm_action_arns             = optional(list(string))
      ok_action_arns                = optional(list(string))
      insufficient_data_action_arns = optional(list(string))
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
