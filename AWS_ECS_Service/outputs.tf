######################################################################
### OUTPUTS

output "ECS_Service" {
  description = "The ECS Service resource object."
  value       = aws_ecs_service.this
}

output "TaskDefinition" {
  description = "The Task Definition resource object."
  value       = aws_ecs_task_definition.this
}

output "CapacityProvider" {
  description = "The Capacity Provider resource object."
  value       = aws_ecs_capacity_provider.this
}

output "AutoScaling_Group" {
  description = "The AutoScaling Group resource object."
  value       = aws_autoscaling_group.this
}

output "LaunchTemplate" {
  description = "The Task Host Launch Template resource object."
  value       = aws_launch_template.this
}

output "Service_Discovery_Service" {
  description = "The Service Discovery Service resource object."
  value       = aws_service_discovery_service.this
}

######################################################################
