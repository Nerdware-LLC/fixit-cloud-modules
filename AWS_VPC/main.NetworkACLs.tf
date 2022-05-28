######################################################################
### NETWORK ACLs

locals {

  # Subnet-Type NACLs ------------------------------------------------

  # Map of subnet types to names of module-provided Subnet-Type NACLs
  SUBNET_TYPE_NACLS_MAP = {
    PUBLIC     = "Public_Subnets_NACL"
    PRIVATE    = "Private_Subnets_NACL"
    INTRA-ONLY = "IntraOnly_Subnets_NACL"
  }

  # Subnet-Type NACL Configs
  SUBNET_TYPE_NACLS = {
    Public_Subnets_NACL = {
      access = {
        ingress = local.COMMON_NACL_RULES # http, https, ephemeral
        egress  = local.COMMON_NACL_RULES # http, https, ephemeral
      }
      tags = { Name = "Public_Subnets_NACL" }
    }
    Private_Subnets_NACL = {
      access = {
        ingress = { "500" = local.COMMON_NACL_RULES["500"] } # ephemeral
        egress  = local.COMMON_NACL_RULES                    # http, https, ephemeral
      }
      tags = { Name = "Private_Subnets_NACL" }
    }
    IntraOnly_Subnets_NACL = {
      access = {
        ingress = {} # none
        egress  = {} # none
      }
      tags = { Name = "IntraOnly_Subnets_NACL" }
    }
  }

  # User NACLs -------------------------------------------------------

  /* Map NACL names to a list of subnet IDs to associate with each respective NACL.
  Note that this object will not include names of Subnet-Type NACLs for types which
  aren't implemented by user. Likewise, if user accidentally included an NACL config
  in var.network_acls, and the name of that NACL is not used in any subnet's
  "custom_network_acl" arg, that NACL will also not be created.  */
  nacl_subnet_ids = {
    for cidr, subnet in local.subnet_resources : coalesce(
      subnet.custom_network_acl,
      local.SUBNET_TYPE_NACLS_MAP[subnet.type]
    ) => subnet.id...
  }

  # Map each NACL name to its respective config
  nacl_configs = {
    for nacl_name, nacl_subnet_ids in local.nacl_subnet_ids : nacl_name => merge(
      { subnet_ids = nacl_subnet_ids }, # <-- merge in the NACL's subnet IDs
      (
        !contains(keys(local.SUBNET_TYPE_NACLS), nacl_name) # is it a totally custom NACL?
        ? var.network_acls[nacl_name]                       # if so, merge user's custom NACL as-is
        : {                                                 # else deep-merge any user overrides
          access = {
            for access_type, default_rules in local.SUBNET_TYPE_NACLS[nacl_name].access
            : access_type => merge(
              default_rules,
              try(var.network_acls[nacl_name].access[access_type], {})
            )
          }
          tags = merge(
            local.SUBNET_TYPE_NACLS[nacl_name].tags,
            try(var.network_acls[nacl_name].tags, {})
          )
        }
      )
    )
  }
}

resource "aws_network_acl" "map" {
  for_each = local.nacl_configs

  vpc_id     = aws_vpc.this.id
  subnet_ids = each.value.subnet_ids

  dynamic "ingress" {
    for_each = try(each.value.access.ingress, [])
    iterator = rule

    content {
      rule_no  = rule.key
      action   = "allow"
      protocol = coalesce(rule.value.protocol, "tcp")
      cidr_block = try(
        one(local.AWS_SERVICE_CIDRS[rule.value.cidr_block]),
        rule.value.cidr_block
      )
      from_port = coalesce(rule.value.from_port, rule.value.port)
      to_port   = coalesce(rule.value.to_port, rule.value.port)
    }
  }

  dynamic "egress" {
    for_each = try(each.value.access.egress, [])
    iterator = rule

    content {
      rule_no  = rule.key
      action   = "allow"
      protocol = coalesce(rule.value.protocol, "tcp")
      cidr_block = try(
        one(local.AWS_SERVICE_CIDRS[rule.value.cidr_block]),
        rule.value.cidr_block
      )
      from_port = coalesce(rule.value.from_port, rule.value.port)
      to_port   = coalesce(rule.value.to_port, rule.value.port)
    }
  }

  tags = each.value.tags
}

#---------------------------------------------------------------------
### Shared Subnet-Type NACL Rules:

locals {
  COMMON_NACL_RULES = {
    "100" = { # HTTP anywhere
      port       = 80
      cidr_block = "0.0.0.0/0"
    }
    "200" = { # HTTPS anywhere
      port       = 443
      cidr_block = "0.0.0.0/0"
    }
    "500" = { # Ephemeral ports
      action     = "allow"
      protocol   = "tcp"
      cidr_block = "0.0.0.0/0"
      from_port  = 1024
      to_port    = 65535
    }
  }
}

# locals {
#   NACL_Rules = flatten([
#     for index, nacl_config in var.network_acls : [
#       for access_type, rules_list in nacl_config.access : flatten([
#         [ # Normalize the provided rule object
#           for rule in rules_list : {
#             network_acl_id = aws_network_acl.list[index].id
#             rule_number    = rule.rule_number
#             action         = "allow"
#             type           = access_type
#             protocol       = coalesce(rule.protocol, "tcp")
#             cidr_block     = rule.cidr_block
#             cidr_block = try(
#               one(local.AWS_SERVICE_CIDRS[rule.cidr_block]),
#               rule.cidr_block
#             )
#             from_port = coalesce(rule.from_port, rule.port)
#             to_port   = coalesce(rule.to_port, rule.port)
#           }
#         ]
#       ])
#     ]
#   ])
# }

# resource "aws_network_acl_rule" "nacl_rules" {
#   count = length(local.NACL_Rules)

#   network_acl_id = local.NACL_Rules[count.index].network_acl_id
#   rule_number    = local.NACL_Rules[count.index].rule_number
#   rule_action    = local.NACL_Rules[count.index].action
#   egress         = local.NACL_Rules[count.index].type == "egress"
#   protocol       = local.NACL_Rules[count.index].protocol
#   cidr_block     = local.NACL_Rules[count.index].cidr_block
#   from_port      = local.NACL_Rules[count.index].from_port
#   to_port        = local.NACL_Rules[count.index].to_port
# }

######################################################################
