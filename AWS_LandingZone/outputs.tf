##################################################
### OUTPUTS

output "Organization" {
  value = aws_organizations_organization.this
}

output "Organizational_Units" {
  value = aws_organizations_organizational_unit.map
}

output "Organization_Member_Accounts" {
  value = aws_organizations_account.map
}

output "Service_Control_Policies" {
  value = aws_organizations_policy.Service_Control_Policies
}

output "Management_Policies" {
  value = aws_organizations_policy.Management_Policies
}

##################################################
