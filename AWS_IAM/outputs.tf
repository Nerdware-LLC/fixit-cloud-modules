######################################################################
### OUTPUTS

output "Custom_IAM_Policies" {
  description = "Map of custom IAM Policy resources by policy name."
  value       = aws_iam_policy.map
}

output "IAM_Roles" {
  description = "Map of IAM Role resource objects."
  value       = aws_iam_role.map
}

output "IAM_Service_Linked_Roles" {
  description = "Map of IAM Service-Linked Role resource objects."
  value       = aws_iam_service_linked_role.map
}

output "IAM_Instance_Profile" {
  description = "Map of Instance Profile resource objects."
  value       = aws_iam_instance_profile.map
}

######################################################################
