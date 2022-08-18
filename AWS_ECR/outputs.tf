######################################################################
### OUTPUTS

output "Repositories" {
  description = "Map of ECR Repository resource objects."
  value       = aws_ecr_repository.map
}

output "Repository_Policies" {
  description = "Map of ECR Repo Policy resource objects."
  value       = aws_ecr_repository_policy.map
}

output "Registry_Scanning_Config" {
  description = "The ECR Registry Scanning Config resource object."
  value       = aws_ecr_registry_scanning_configuration.this
}

output "Registry_Policy" {
  description = "The ECR Registry Policy resource object."
  value       = one(aws_ecr_registry_policy.list)
}

######################################################################
