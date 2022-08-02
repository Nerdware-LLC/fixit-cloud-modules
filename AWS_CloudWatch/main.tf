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

  name           = coalesce(each.value.log_metric_filter.name, each.key)
  pattern        = each.value.log_metric_filter.pattern
  log_group_name = each.value.log_metric_filter.log_group_name

  metric_transformation {
    namespace  = each.value.namespace                   # required
    name       = each.value.metric_transformation.name  # required
    value      = each.value.metric_transformation.value # required ("1" = count each occurrence of the keywords in the filter)
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
  for_each = var.cloudwatch_metrics

  alarm_name        = coalesce(each.value.alarm.name, each.key)
  alarm_description = each.value.alarm.description
  namespace         = each.value.namespace
  metric_name       = aws_cloudwatch_log_metric_filter.map[each.key].id

  # ACTIONS
  alarm_actions             = [one(aws_sns_topic.CloudWatch_CIS_Alarms).arn]
  insufficient_data_actions = [] # TODO review this one <---

  # TODO parameterize the ones below
  comparison_operator = "GreaterThanOrEqualToThreshold"
  statistic           = "Sum"
  threshold           = "1"
  period              = "300"
  evaluation_periods  = "1"
  treat_missing_data  = "notBreaching"

  tags = each.value.alarm.tags
}

#---------------------------------------------------------------------
### CloudWatch Dashboards

resource "aws_cloudwatch_dashboard" "map" {
  for_each = var.cloudwatch_dashboards

  dashboard_name = each.key
  dashboard_body = each.value
}

######################################################################
