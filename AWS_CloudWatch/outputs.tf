######################################################################
### OUTPUTS

output "CloudWatch_Logs_Log_Groups" {
  description = "Map of CloudWatch Logs log group resource objects."
  value       = aws_cloudwatch_log_group.map
}

output "CloudWatch_Log_Metric_Filters" {
  description = "Map of CloudWatch log metric filter resource objects."
  value       = aws_cloudwatch_log_metric_filter.map
}

output "CloudWatch_Metric_Alarm" {
  description = "Map of CloudWatch alarm resource objects."
  value       = aws_cloudwatch_metric_alarm.map
}

output "CloudWatch_Dashboards" {
  description = "Map of CloudWatch dashboard resource objects."
  value       = aws_cloudwatch_dashboard.map
}

######################################################################
