##################################################
### Organization Policies

/* Four kinds of organization policies:
    1) Service Control Policies
    2) AI Services Opt-Out Policies
    3) Backup Policy
    4) Tag Policy
*/

resource "aws_organizations_policy" "map" {
  for_each = var.organization_policies

  name        = each.key
  description = each.value.description
  type        = each.value.type
  content     = each.value.statement
  tags        = each.value.tags
}

resource "aws_organizations_policy_attachment" "map" {
  for_each = var.organization_policies

  policy_id = aws_organizations_policy.map[each.key].id
  target_id = (each.value.target == "root"
    ? aws_organizations_organization.this.master_account_id
    : local.all_org_units[each.value.target].id
  )
}

##################################################
