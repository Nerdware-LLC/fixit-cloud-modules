##################################################
### Organization SCPs (Service Control Policies)

resource "aws_organizations_policy" "Service_Control_Policies" {
  for_each = var.service_control_policies

  name        = each.key
  description = each.value.description
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      for statement in each.value.statements : {
        for key, value in statement : key => value
        if value != null # ignore empty optional properties
      }
    ]
  })

  tags = each.value.tags
}

resource "aws_organizations_policy_attachment" "scp_attachments" {
  for_each = var.service_control_policies

  policy_id = aws_organizations_policy.Service_Control_Policies[each.key].id
  target_id = (each.value.target == "root"
    ? aws_organizations_organization.this.master_account_id
    : aws_organizations_organizational_unit.map[each.value.target].id
  )
}

#-------------------------------------------------
### Organization Management Policies

/* Three kinds of management policies:
      1) AI services opt-out policies
      2) Backup policy
      3) Tag policy
*/

resource "aws_organizations_policy" "Management_Policies" {
  for_each = var.management_policies

  name        = each.key
  description = each.value.description
  type        = each.value.type
  content     = jsonencode(each.value.content)
  tags        = each.value.tags
}

resource "aws_organizations_policy_attachment" "mgmt_policy_attachments" {
  for_each = var.management_policies

  policy_id = aws_organizations_policy.Management_Policies[each.key].id
  target_id = (each.value.target == "root"
    ? aws_organizations_organization.this.master_account_id
    : aws_organizations_organizational_unit.map[each.value.target].id
  )
}

##################################################
