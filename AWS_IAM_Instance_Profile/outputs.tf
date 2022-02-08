######################################################################
### OUTPUTS

output "IAM_Instance_Profile" {
  description = "Instance Profile resource object."
  value       = aws_iam_instance_profile.this
}

output "IAM_Role" {
  description = "IAM Role resource object."
  value       = aws_iam_role.this
}

output "Custom_IAM_Policies" {
  description = "Map of custom IAM Policy resources by policy_name."
  value       = aws_iam_policy.map
}

output "EC2_Key_Pair" {
  description = "The EC2 Key Pair resource object."
  value       = one(aws_key_pair.this)
  sensitive   = true
}

######################################################################
