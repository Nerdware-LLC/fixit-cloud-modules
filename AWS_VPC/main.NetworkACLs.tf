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
    }
    Private_Subnets_NACL = {
      access = {
        ingress = { "500" = local.COMMON_NACL_RULES["500"] } # ephemeral
        egress  = local.COMMON_NACL_RULES                    # http, https, ephemeral
      }
    }
    IntraOnly_Subnets_NACL = {
      access = {
        ingress = {} # none
        egress  = {} # none
      }
    }
  }

  # User NACLs -------------------------------------------------------

  /* Map NACL names to a list of subnet IDs to associate with each respective NACL.
  Note that this object will not include names of Subnet-Type NACLs for types which
  aren't implemented by user. Likewise, if user accidentally included an NACL config
  in var.network_acls, and the name of that NACL is not used in any subnet's
  "network_acl" arg, that NACL will also not be created.  */
  nacl_subnet_ids = {
    for cidr, subnet in local.subnet_resources : coalesce(
      subnet.network_acl,
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
          tags = try(var.network_acls[nacl_name].tags, {})
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
    for_each = try(coalesce(each.value.access.ingress, []), [])
    iterator = rule

    content {
      rule_no  = rule.value
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
    for_each = try(coalesce(each.value.access.egress, []), [])
    iterator = rule

    content {
      rule_no  = rule.value
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

  lifecycle {
    # Ensure any NACL rule "cidr_block" AWS service strings returned valid value from aws_ip_ranges data source.
    precondition {
      condition = alltrue([
        for nacl_name, nacl in var.network_acls : alltrue([
          for access_type, rules_map in coalesce(nacl.access, {}) : alltrue([
            for rule_config in values(coalesce(rules_map, {})) : alltrue([
              # If "cidr_block" is an AWS service string, ensure we have 1 CIDR for it.
              (
                !contains(["ec2_instance_connect", "globalaccelerator"], rule_config.cidr_block) ||
                try(
                  length(local.AWS_SERVICE_CIDRS[rule_config.cidr_block]) == 1,
                  true # <-- prevent lookup error on evaluation
                )
              ),
            ])
          ])
        ])
      ])
      error_message = "The \"aws_ip_ranges\" data source did not provide a CIDR for one or more of your NACL rule \"cidr_block\" AWS service strings."
    }
  }
}

#---------------------------------------------------------------------
### Shared Subnet-Type NACL Rules:

locals {
  COMMON_NACL_RULES = {
    "100" = { # HTTP anywhere
      protocol   = "tcp"
      cidr_block = "0.0.0.0/0"
      from_port  = 80
      to_port    = 80
    }
    "200" = { # HTTPS anywhere
      protocol   = "tcp"
      cidr_block = "0.0.0.0/0"
      from_port  = 443
      to_port    = 443
    }
    "500" = { # Ephemeral ports
      protocol   = "tcp"
      cidr_block = "0.0.0.0/0"
      from_port  = 1024
      to_port    = 65535
    }
  }
}

######################################################################
