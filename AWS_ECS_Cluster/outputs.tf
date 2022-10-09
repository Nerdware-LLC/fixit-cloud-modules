######################################################################
### OUTPUTS

output "ECS_Cluster" {
  description = "The ECS Cluster resource object."
  value       = aws_ecs_cluster.this
}

#---------------------------------------------------------------------
### ECS Service Outputs

output "ECS_Services" {
  description = "Map of ECS Service resource objects."
  value       = aws_ecs_service.map
}

#---------------------------------------------------------------------
### Task Definition Outputs

output "Task_Definition" {
  description = "Map of Task Definition resource objects."
  value       = aws_ecs_task_definition.map
}

#---------------------------------------------------------------------
### Capacity Provider Outputs

output "Capacity_Providers" {
  description = "Map of Capacity Provider resource objects."
  value       = aws_ecs_capacity_provider.map
}

#---------------------------------------------------------------------
### AutoScaling Group Outputs

output "AutoScaling_Groups" {
  description = "Map of AutoScaling Group resource objects."
  value       = aws_autoscaling_group.map
}

#---------------------------------------------------------------------
### Task Host Launch Template Outputs

output "Task_Host_Launch_Template" {
  description = "Map of Task Host Launch Template resource objects."
  value       = aws_launch_template.map
}

#---------------------------------------------------------------------
### Service Discovery Outputs

output "Service_Discovery_Namespace" {
  description = "The Service Discovery \"private DNS\" Namespace resource object."
  value       = aws_service_discovery_private_dns_namespace.this
}

output "Service_Discovery_Services" {
  description = "Map of Service Discovery Service resource objects."
  value       = aws_service_discovery_service.map
}

#---------------------------------------------------------------------
### AppMesh Outputs

output "AppMesh" {
  description = "The App Mesh resource object."
  value       = aws_appmesh_mesh.this
}

output "AppMesh_Services" {
  description = "Map of App Mesh Virtual Service resource objects."
  value       = aws_appmesh_virtual_service.map
}

output "AppMesh_Nodes" {
  description = "Map of App Mesh Virtual Node resource objects."
  value       = aws_appmesh_virtual_node.map
}

output "AppMesh_Routers" {
  description = "Map of App Mesh Virtual Router resource objects."
  value       = aws_appmesh_virtual_router.map
}

output "AppMesh_Routes" {
  description = "Map of App Mesh Route resource objects."
  value       = aws_appmesh_route.map
}

######################################################################
