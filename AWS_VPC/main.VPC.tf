######################################################################

locals {
  public_subnets = {
    for cidr, subnet in var.subnets : cidr => subnet
    if subnet.egress_destination == "INTERNET_GATEWAY"
  }

  private_subnets = {
    for cidr, subnet in var.subnets : cidr => subnet
    if subnet.egress_destination == "NAT_GATEWAY"
  }

  # TODO account for peered subnets
  # peered_subnets = {
  #   for cidr, subnet in var.subnets : cidr => subnet
  #   if can(cidrsubnet(subnet.egress_destination, 4, 0))
  # }

  # TODO account for closed subnets
  # closed_subnets = {
  #   for cidr, subnet in var.subnets : cidr => subnet
  #   if subnet.egress_destination == "NONE"
  # }
}

#---------------------------------------------------------------------
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
  map_public_ip_on_launch = each.value.map_public_ip_on_launch == true
  tags                    = each.value.tags
}

######################################################################
