######################################################################
### OUTPUTS

output "ECS_Cluster" {
  description = "The ECS Cluster resource object."
  value       = aws_ecs_cluster.this
}

output "ECS_Cluster_CloudWatch_LogGroup" {
  description = "The CloudWatch Logs log group for the ECS Cluster."
  value       = aws_cloudwatch_log_group.ECS_Cluster_CloudWatch_LogGroup
}

output "Default_CapacityProvider" {
  description = "The cluster's default Capacity Provider resource object."
  value       = aws_ecs_capacity_provider.Default_CapacityProvider
}

output "Default_CapacityProvider_AutoScaling_Group" {
  description = "The AutoScaling Group resource of the cluster's default capacity provider."
  value       = aws_autoscaling_group.Default_CapacityProvider
}

output "Default_CapacityProvider_AutoScaling_Group_LaunchTemplate" {
  description = "The Launch Template resource used in the default capacity provider's autoscaling group."
  value       = aws_launch_template.Default_CapacityProvider
}

output "ECS_Service_Discovery_Namespace" {
  description = "The cluster's Service Discovery Namespace resource object."
  value       = aws_service_discovery_private_dns_namespace.ECS_Service_Discovery_Namespace
}

######################################################################
