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

#--------------------------------------------------
# Organizational Units

locals {
  /* TODO move the below explainer to the README
  To avoid CYCLE ERRORs in nested organizational_unit resources, 
  we need to have separate resource blocks - one for each nesting depth 
  within the organization's structure. AWS allows organizations to have a
  maximum nesting depth of 5, which includes the root account as well as
  account leaf-nodes within the org tree. Therefore, our implementation 
  can provide 3 OU nesting levels:
      Level_1   --> OUs that are direct children of root
      Level_2   --> OUs that are direct children of L1 OUs
      Level_3   --> OUs that are direct children of L2 OUs
  */
  Level_1_OUs = {
    for ou_name, ou_config in var.organizational_units : ou_name => ou_config
    if ou_config.parent == "root"
  }
  Level_2_OUs = {
    for ou_name, ou_config in var.organizational_units : ou_name => ou_config
    if contains(keys(local.Level_1_OUs), ou_config.parent)
  }
  Level_3_OUs = {
    for ou_name, ou_config in var.organizational_units : ou_name => ou_config
    if contains(keys(local.Level_2_OUs), ou_config.parent)
  }
}


resource "aws_organizations_organizational_unit" "Level_1_OUs" {
  for_each = local.Level_1_OUs

  name      = each.key
  parent_id = aws_organizations_organization.this.master_account_id
  tags      = each.value.tags
}

resource "aws_organizations_organizational_unit" "Level_2_OUs" {
  for_each = local.Level_2_OUs

  name      = each.key
  parent_id = aws_organizations_organizational_unit.Level_1_OUs[each.value.parent].id
  tags      = each.value.tags
}

resource "aws_organizations_organizational_unit" "Level_3_OUs" {
  for_each = local.Level_3_OUs

  name      = each.key
  parent_id = aws_organizations_organizational_unit.Level_2_OUs[each.value.parent].id
  tags      = each.value.tags
}

locals {
  /* This local is used by
    - resource aws_organizations_account
    - resource aws_organizations_policy_attachment
    - output   Organizational_Units
  */
  all_org_units = merge(
    aws_organizations_organizational_unit.Level_1_OUs,
    aws_organizations_organizational_unit.Level_2_OUs,
    aws_organizations_organizational_unit.Level_3_OUs
  )
}

#--------------------------------------------------
# Member/Child Accounts

resource "aws_organizations_account" "map" {
  for_each = var.member_accounts

  name      = each.key
  email     = each.value.email
  parent_id = local.all_org_units[each.value.parent].id
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
