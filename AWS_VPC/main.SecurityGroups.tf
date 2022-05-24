######################################################################
### SECURITY GROUPS

resource "aws_security_group" "map" {
  for_each = var.security_groups

  vpc_id      = aws_vpc.this.id
  name        = each.key
  description = each.value.description
  tags        = each.value.tags
}

#---------------------------------------------------------------------
### SECURITY GROUP RULES

/* All sec group rule config objects are normalized in the following manner:
    • field added => 'security_group_id'
    • field added => 'type'
    • field added => 'protocol' IF not provided
    • fields 'from_port' and 'to_port' are added if alt field 'port' was provided
    • field 'peer_security_group_id' is added if alt field 'peer_security_group' was provided
    • of fields (peer_security_group_id, peer_security_group, cidr_blocks, self), only 1 should have a value, the others = null
*/

locals {
  SecGroup_Rules = flatten([
    for sg_name, sg_config in var.security_groups : [
      for access_type, rules_list in sg_config.access : [
        for rule in rules_list : {
          # security_group_id = ID of the sec group to which the rule belongs
          security_group_id = aws_security_group.map[sg_name].id
          description       = rule.description
          type              = access_type
          protocol          = coalesce(rule.protocol, "tcp")
          from_port         = coalesce(rule.from_port, rule.port)
          to_port           = coalesce(rule.to_port, rule.port)
          peer_security_group_id = try(
            aws_security_group.map[rule.peer_security_group].id,
            rule.peer_security_group_id # optional, may be null
          )
          cidr_blocks = try(
            local.AWS_SERVICE_CIDRS[rule.aws_service],
            rule.cidr_blocks # optional, may be null
          )
          self = rule.self # optional, may be null
        }
      ]
    ]
  ])
}

# Note: tfsec-ignore used for "description" due to erroneous flagging (description var is required)
resource "aws_security_group_rule" "list" {
  count = length(local.SecGroup_Rules)

  # REQUIRED:
  security_group_id = local.SecGroup_Rules[count.index].security_group_id
  description       = local.SecGroup_Rules[count.index].description #tfsec:ignore:aws-vpc-add-description-to-security-group
  type              = local.SecGroup_Rules[count.index].type
  protocol          = local.SecGroup_Rules[count.index].protocol
  from_port         = local.SecGroup_Rules[count.index].from_port
  to_port           = local.SecGroup_Rules[count.index].to_port

  # ONLY 1 OF THESE ALLOWED:
  source_security_group_id = local.SecGroup_Rules[count.index].peer_security_group_id
  cidr_blocks              = local.SecGroup_Rules[count.index].cidr_blocks
  self                     = local.SecGroup_Rules[count.index].self
}

######################################################################
