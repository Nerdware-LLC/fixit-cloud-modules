######################################################################
### OUTPUTS

output "SNS_Topics" {
  description = "Map of SNS Topic resource objects."
  value       = aws_sns_topic.map
}

output "SNS_Topic_Policies" {
  description = "Map of SNS Topic Policy resource objects."
  value       = aws_sns_topic_policy.map
}

output "SNS_Topic_Subscriptions" {
  description = "Map of SNS Topic Subscription resource objects."
  value       = aws_sns_topic_subscription.map
}

######################################################################
