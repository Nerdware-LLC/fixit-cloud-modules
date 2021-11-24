##################################################
### AWS ORGANIZATION

# The root "management" account
resource "aws_organizations_organization" "this" {
  feature_set = (
    coalesce(var.organization_config.should_enable_all_features, true)
    ? "ALL"
    : "CONSOLIDATED_BILLING"
  )
  aws_service_access_principals = var.organization_config.org_trusted_services
  enabled_policy_types          = var.organization_config.enabled_policy_types
}

# Organizational Units
resource "aws_organizations_organizational_unit" "map" {
  for_each = var.organizational_units

  name = each.key
  parent_id = (each.value.parent == "root"
    ? aws_organizations_organization.this.master_account_id
    : aws_organizations_organizational_unit.map[each.value.parent].id
  )
  tags = each.value.tags
}

# Member/child accounts
resource "aws_organizations_account" "map" {
  for_each = var.member_accounts

  name  = each.key
  email = each.value.email
  parent_id = (each.value.parent == "root"
    ? aws_organizations_organization.this.master_account_id
    : aws_organizations_organizational_unit.map[each.value.parent].id
  )
  iam_user_access_to_billing = (
    coalesce(each.value.should_allow_iam_user_access_to_billing, true)
    ? "ALLOW"
    : "DENY"
  )
  role_name = coalesce(
    each.value.org_account_access_role_name,
    "OrganizationAccountAccessRole"
  )
  tags = each.value.tags

  lifecycle {
    # Recommended by TF registry docs:
    ignore_changes = [role_name]
  }
}

##################################################
