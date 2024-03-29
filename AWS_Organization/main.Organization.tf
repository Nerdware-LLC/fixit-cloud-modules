######################################################################
### AWS ORGANIZATION
######################################################################
### root "management" account

resource "aws_organizations_organization" "this" {
  feature_set                   = "ALL"
  aws_service_access_principals = var.organization_config.org_trusted_services
  enabled_policy_types          = var.organization_config.enabled_policy_types
}

#---------------------------------------------------------------------
### Organizational Units                    (AWS OU max nest depth: 5)

resource "aws_organizations_organizational_unit" "Level_1_OUs" {
  for_each = {
    for ou_name, ou_config in var.organizational_units : ou_name => ou_config
    if ou_config.parent == "root"
  }

  name      = each.key
  parent_id = one(aws_organizations_organization.this.roots).id
  tags      = each.value.tags
}

resource "aws_organizations_organizational_unit" "Level_2_OUs" {
  for_each = {
    for ou_name, ou_config in var.organizational_units : ou_name => ou_config
    if contains(keys(aws_organizations_organizational_unit.Level_1_OUs), ou_config.parent)
  }

  name      = each.key
  parent_id = aws_organizations_organizational_unit.Level_1_OUs[each.value.parent].id
  tags      = each.value.tags
}

resource "aws_organizations_organizational_unit" "Level_3_OUs" {
  for_each = {
    for ou_name, ou_config in var.organizational_units : ou_name => ou_config
    if contains(keys(aws_organizations_organizational_unit.Level_2_OUs), ou_config.parent)
  }

  name      = each.key
  parent_id = aws_organizations_organizational_unit.Level_2_OUs[each.value.parent].id
  tags      = each.value.tags
}

resource "aws_organizations_organizational_unit" "Level_4_OUs" {
  for_each = {
    for ou_name, ou_config in var.organizational_units : ou_name => ou_config
    if contains(keys(aws_organizations_organizational_unit.Level_3_OUs), ou_config.parent)
  }

  name      = each.key
  parent_id = aws_organizations_organizational_unit.Level_3_OUs[each.value.parent].id
  tags      = each.value.tags
}

resource "aws_organizations_organizational_unit" "Level_5_OUs" {
  for_each = {
    for ou_name, ou_config in var.organizational_units : ou_name => ou_config
    if contains(keys(aws_organizations_organizational_unit.Level_4_OUs), ou_config.parent)
  }

  name      = each.key
  parent_id = aws_organizations_organizational_unit.Level_4_OUs[each.value.parent].id
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
    aws_organizations_organizational_unit.Level_3_OUs,
    aws_organizations_organizational_unit.Level_4_OUs,
    aws_organizations_organizational_unit.Level_5_OUs
  )
}

#---------------------------------------------------------------------
### Member/Child Accounts

resource "aws_organizations_account" "map" {
  for_each = var.member_accounts

  name      = each.key
  email     = each.value.email
  parent_id = local.all_org_units[each.value.parent].id
  iam_user_access_to_billing = (
    each.value.should_allow_iam_user_access_to_billing != false
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

#---------------------------------------------------------------------
### Delegated Administrator Accounts

resource "aws_organizations_delegated_administrator" "map" {
  for_each = var.delegated_administrators

  service_principal = each.key
  account_id        = aws_organizations_account.map[each.value].id
}

######################################################################
