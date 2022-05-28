######################################################################
### VPC

resource "aws_vpc" "this" {
  cidr_block           = var.vpc.cidr_block
  enable_dns_support   = coalesce(var.vpc.enable_dns_support, true)
  enable_dns_hostnames = coalesce(var.vpc.enable_dns_hostnames, true)
  tags                 = var.vpc.tags
}

#---------------------------------------------------------------------
### SUBNETS

locals {
  # For aws_subnet precondition blocks:
  SUBNET_TYPE_VALID_CUSTOM_ROUTE_TABLES = {
    # PUBLIC subnets must use an RT defined in var.route_tables
    PUBLIC = keys(var.route_tables)
    # PRIVATE subnets must use the CIDR of a subnet which contains a NAT gateway
    PRIVATE    = [for cidr, subnet in var.subnets : cidr if subnet.contains_nat_gateway == true]
    INTRA-ONLY = []
  }

  # After resource evaluation, merge var.subnets configs with their aws_subnet resource attributes
  subnet_resources = {
    for cidr, subnet in var.subnets : cidr => merge(
      subnet,                           # <-- does not contain "cidr" property
      aws_subnet.map[cidr],             # <-- contains "cidr_block" and "id"
      {                                 # convenient property aliases:
        cidr = cidr                     # <-- allows reference to either "cidr" or "cidr_block"
        az   = subnet.availability_zone # <-- allows abbreviated refs to "availability_zone"
      }
    )
  }

  # Group subnets by type - obj won't include keys of unused subnet types
  subnets_by_type = {
    for subnet_type, list_of_subnets_of_type in {
      for cidr, subnet in local.subnet_resources : subnet.type => { "${cidr}" = subnet }... # <-- group subnets by type
    } : subnet_type => merge(list_of_subnets_of_type...)                                    # <-- spread and merge grouped subnets
  }
}

resource "aws_subnet" "map" {
  for_each = var.subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.key
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = coalesce(each.value.map_public_ip_on_launch, false)
  tags                    = each.value.tags

  lifecycle {
    # Ensure "custom_route_table" values are valid
    precondition {
      condition = alltrue([
        for cidr, subnet in var.subnets : contains([
          # The list of acceptable non-null values depends on subnet type, but can always be null.
          flatten([null, local.SUBNET_TYPE_VALID_CUSTOM_ROUTE_TABLES[subnet.type]]),
          subnet.custom_route_table
        ])
      ])
      error_message = "All subnet \"custom_route_table\" values must be valid route tables for each subnet's type."
    }

    # Ensure every "custom_network_acl" value is either null, or exists as a key in "var.network_acls"
    precondition {
      condition = alltrue([
        for cidr, subnet in var.subnets : contains(
          flatten([null, keys(var.network_acls)]),
          subnet.custom_network_acl
        )
      ])
      error_message = "All subnet \"custom_network_acl\" values must match a custom NACL named in the \"network_acls\" variable."
    }
  }
}

######################################################################
