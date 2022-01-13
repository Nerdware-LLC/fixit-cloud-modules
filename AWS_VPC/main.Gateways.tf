######################################################################

locals {
  SHOULD_CREATE_INTERNET_GW = length(values(local.public_subnets)) > 0
  SHOULD_CREATE_NAT_GW      = length(values(local.private_subnets)) > 0
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
