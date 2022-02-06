######################################################################
### NETWORK ACLs

resource "aws_network_acl" "list" {
  count = length(var.network_acl_configs)

  vpc_id     = aws_vpc.this.id
  subnet_ids = [for cidr in var.network_acl_configs[count.index].subnet_cidrs : aws_subnet.map[cidr].id]
  tags       = var.network_acl_configs[count.index].tags
}

#---------------------------------------------------------------------
### Network ACL Rules

locals {
  NACL_Rules = flatten([
    for index, nacl_config in var.network_acl_configs : [
      for access_type, rules_list in nacl_config.access : flatten([
        [ # Normalize the provided rule object
          for rule in rules_list : {
            network_acl_id = aws_network_acl.list[index].id
            rule_number    = rule.rule_number
            action         = "allow"
            type           = access_type
            protocol       = coalesce(rule.protocol, "tcp")
            cidr_block     = rule.cidr_block
            cidr_block = try(
              one(local.AWS_SERVICE_CIDRs[rule.cidr_block]),
              rule.cidr_block
            )
            from_port = coalesce(rule.from_port, rule.port)
            to_port   = coalesce(rule.to_port, rule.port)
          }
        ]
      ])
    ]
  ])
}

resource "aws_network_acl_rule" "nacl_rules" {
  count = length(local.NACL_Rules)

  network_acl_id = local.NACL_Rules[count.index].network_acl_id
  rule_number    = local.NACL_Rules[count.index].rule_number
  rule_action    = local.NACL_Rules[count.index].action
  egress         = local.NACL_Rules[count.index].type == "egress"
  protocol       = local.NACL_Rules[count.index].protocol
  cidr_block     = local.NACL_Rules[count.index].cidr_block
  from_port      = local.NACL_Rules[count.index].from_port
  to_port        = local.NACL_Rules[count.index].to_port
}

######################################################################
