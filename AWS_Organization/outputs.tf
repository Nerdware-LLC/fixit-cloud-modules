######################################################################
### OUTPUTS

output "Organization" {
  description = "The AWS Organization resource object."
  value       = aws_organizations_organization.this
}

output "Organizational_Units" {
  description = "Map of Organizational Unit resource objects."
  value       = local.all_org_units
}

output "Organization_Member_Accounts" {
  description = "Map of Organization Member Account resource objects."
  value       = aws_organizations_account.map
}

output "Organization_Policies" {
  description = "Map of Organization Policy resource objects."
  value       = aws_organizations_policy.map
}

######################################################################
