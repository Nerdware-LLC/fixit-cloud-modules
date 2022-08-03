######################################################################
### AWS CloudWatch
######################################################################
### CloudWatch Logs - Log Groups

resource "aws_cloudwatch_log_group" "map" {
  for_each = var.cloudwatch_logs_log_groups

  name              = each.key
  retention_in_days = coalesce(each.value.retention_in_days, 400)
  kms_key_id        = each.value.kms_key_arn
  tags              = each.value.tags
}

#---------------------------------------------------------------------
### CloudWatch Metrics

resource "aws_cloudwatch_log_metric_filter" "map" {
  for_each = var.cloudwatch_log_metric_filters

  name           = each.key
  pattern        = each.value.log_metric_filter.pattern
  log_group_name = each.value.log_metric_filter.log_group_name

  metric_transformation {
    namespace  = each.value.metric_transformation.namespace # required
    name       = each.value.metric_transformation.name      # required
    value      = each.value.metric_transformation.value     # required ("1" = count each occurrence of the keywords in the filter)
    dimensions = each.value.metric_transformation.dimensions
    unit       = each.value.metric_transformation.unit
    default_value = (
      each.value.metric_transformation.default_value != null || each.value.metric_transformation.dimensions != null
      ? each.value.metric_transformation.default_value
      : 0
    )
  }
}

#---------------------------------------------------------------------
### CloudWatch Alarms

resource "aws_cloudwatch_metric_alarm" "map" {
  for_each = var.cloudwatch_metric_alarms

  # ALARM
  alarm_name        = each.key
  alarm_description = each.value.description
  tags              = each.value.tags

  # STATIC METRIC
  namespace   = try(each.value.static_metric.namespace, null)
  metric_name = try(each.value.static_metric.name, null)
  statistic   = try(each.value.static_metric.statistic, null)
  period      = try(each.value.static_metric.period, null)
  unit        = try(each.value.static_metric.unit, null)
  dimensions  = try(each.value.static_metric.dimensions, null)
  threshold   = try(each.value.static_metric.threshold, null)
  # TODO Add support for "extended_statistic" ("p0.0" to "p100")

  # METRIC QUERIES
  dynamic "metric_query" {
    for_each = each.value.metric_queries != null ? each.value.metric_queries : {}

    content {
      id          = metric_query.key
      account_id  = metric_query.value.account_id
      expression  = metric_query.value.expression
      label       = metric_query.value.label
      return_data = coalesce(metric_query.value.return_data, false)

      dynamic "metric" {
        for_each = metric_query.value.metric != null ? [metric_query.value.metric] : []

        content {
          namespace   = metric.value.namespace
          metric_name = metric.value.name
          stat        = metric.value.statistic
          period      = metric.value.period
          unit        = metric.value.unit
          dimensions  = metric.value.dimensions
        }
      }
    }
  }

  # METRIC QUERIES: THRESHOLD
  threshold_metric_id = (
    each.value.metric_queries != null
    ? one([for id, query in each.value.metric_queries : id if query.use_to_set_threshold == true])
    : null
  )

  # THRESHOLD EVALUATION
  comparison_operator = each.value.comparison_operator # Required
  evaluation_periods  = each.value.evaluation_periods
  datapoints_to_alarm = each.value.datapoints_to_alarm
  treat_missing_data  = each.value.treat_missing_data

  # ACTIONS
  actions_enabled           = coalesce(each.value.actions_enabled, true) # Default: true
  alarm_actions             = each.value.alarm_action_arns
  ok_actions                = each.value.ok_action_arns
  insufficient_data_actions = each.value.insufficient_data_action_arns
}

# TODO Add support for composite alarms.

#---------------------------------------------------------------------
### CloudWatch Dashboards

resource "aws_cloudwatch_dashboard" "map" {
  for_each = var.cloudwatch_dashboards

  dashboard_name = each.key
  dashboard_body = each.value
}

######################################################################
