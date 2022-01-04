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

  SHOULD_CREATE_INTERNET_GW = length(values(local.public_subnets)) > 0
  SHOULD_CREATE_NAT_GW      = length(values(local.private_subnets)) > 0
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

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.key
  availability_zone = each.value.availability_zone
  tags              = each.value.tags
}

#---------------------------------------------------------------------
### INTERNET GATEWAY

resource "aws_internet_gateway" "this" {
  count = local.SHOULD_CREATE_INTERNET_GW ? 1 : 0

  vpc_id = aws_vpc.this.id
  tags   = var.gateway_tags.internet_gateway
}

#---------------------------------------------------------------------
### NAT GATEWAY

resource "aws_nat_gateway" "this" {
  count = local.SHOULD_CREATE_NAT_GW ? 1 : 0

  allocation_id = one(aws_eip.NAT_GW_EIP).allocation_id
  subnet_id = one([
    for cidr, subnet in aws_subnet.map : subnet.id
    if var.subnets[cidr].contains_nat_gateway == true
  ])
  tags = var.gateway_tags.nat_gateway

  depends_on = [aws_internet_gateway.this]
}

resource "aws_eip" "NAT_GW_EIP" {
  count = local.SHOULD_CREATE_NAT_GW ? 1 : 0

  vpc  = true
  tags = var.gateway_tags.nat_gateway_elastic_ip

  depends_on = [aws_internet_gateway.this]
}

######################################################################
