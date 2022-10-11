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

resource "aws_subnet" "map" {
  for_each = var.subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.key
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = coalesce(each.value.map_public_ip_on_launch, false)
  tags                    = each.value.tags
}

locals {
  # Merge var.subnets configs with their aws_subnet resource attributes
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
      # tflint-ignore: terraform_deprecated_interpolation
      for cidr, subnet in local.subnet_resources : subnet.type => { "${cidr}" = subnet }... # <-- group subnets by type
    } : subnet_type => merge(list_of_subnets_of_type...)                                    # <-- spread and merge grouped subnets
  }
}

######################################################################
