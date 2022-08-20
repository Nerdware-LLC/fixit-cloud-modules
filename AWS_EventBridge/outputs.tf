######################################################################
### OUTPUTS

output "Event_Buses" {
  description = "Map of EventBridge Event Bus resource objects."
  value       = aws_cloudwatch_event_bus.map
}

output "Event_Bus_Policies" {
  description = "Map of EventBridge Event Bus Policy resource objects."
  value       = aws_cloudwatch_event_bus_policy.map
}

output "Event_Rules" {
  description = "Map of EventBridge Event Rule resource objects."
  value       = aws_cloudwatch_event_rule.map
}

output "Event_Targets" {
  description = "Map of EventBridge Event Target resource objects."
  value       = aws_cloudwatch_event_target.map
}

######################################################################
