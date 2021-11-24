##################################################
### OUTPUTS

output "Organization" {
  value = aws_organizations_organization.this
}

output "Organizational_Units" {
  value = local.all_org_units
}

output "Organization_Member_Accounts" {
  value = aws_organizations_account.map
}

output "Organization_Policies" {
  value = aws_organizations_policy.map
}

##################################################
