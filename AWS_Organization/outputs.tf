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

output "Delegated_Administrators" {
  description = "Map of Delegated Admin resource objects."
  value       = aws_organizations_delegated_administrator.map
}

output "Organization_Policies" {
  description = "Map of Organization Policy resource objects."
  value       = aws_organizations_policy.map
}

#---------------------------------------------------------------------
### SSO Outputs

output "SSO_Admin_Permission_Set" {
  description = "The SSO Admin Permission Set resource object for \"AdministratorAccess\"."
  value       = aws_ssoadmin_permission_set.AdministratorAccess
}

output "SSO_Admin_Managed_Policy_Attachment" {
  description = "The SSO Admin Permission Set resource object."
  value       = aws_ssoadmin_managed_policy_attachment.AdministratorAccess
}

output "SSO_Admin_Account_Assignments" {
  description = "Map of SSO Admin Account Assignment resource objects."
  value       = aws_ssoadmin_account_assignment.map
}

#---------------------------------------------------------------------
### Access Analyzer Outputs

output "Org_Access_Analyzer" {
  description = "The Organization's Access Analyzer resource object."
  value       = aws_accessanalyzer_analyzer.this
}

######################################################################
