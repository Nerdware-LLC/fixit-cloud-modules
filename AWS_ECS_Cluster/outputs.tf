######################################################################
### OUTPUTS

output "ECS_Cluster" {
  description = "The ECS Cluster resource object."
  value       = aws_ecs_cluster.this
}

output "ECS_Cluster_CapacityProviders" {
  description = "The cluster's Capacity Provider resource objects."
  value       = aws_ecs_cluster_capacity_providers.this
}

output "ECS_Service_Discovery_Namespace" {
  description = "The cluster's Service Discovery Namespace resource object."
  value       = aws_service_discovery_private_dns_namespace.this
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
