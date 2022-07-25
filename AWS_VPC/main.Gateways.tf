######################################################################
### GATEWAYS
######################################################################
### Internet Gateway

resource "aws_internet_gateway" "list" {
  count = contains(values(var.subnets)[*].type, "PUBLIC") ? 1 : 0

  vpc_id = aws_vpc.this.id
  tags   = var.internet_gateway_tags
}

#---------------------------------------------------------------------
### NAT Gateways

locals {
  public_subnets_with_nat_gw = {
    for cidr, subnet in lookup(local.subnets_by_type, "PUBLIC", {}) : cidr => subnet
    if subnet.contains_nat_gateway == true
  }
}

resource "aws_nat_gateway" "map" {
  for_each = local.public_subnets_with_nat_gw # keys --> public subnet CIDRs

  allocation_id = aws_eip.nat_gw_elastic_ips[each.key].allocation_id
  subnet_id     = each.value.id
  tags = (
    var.nat_gateway_tags != null
    ? lookup(var.nat_gateway_tags, each.value.cidr, null)
    : null
  )

  depends_on = [aws_internet_gateway.list]
}

resource "aws_eip" "nat_gw_elastic_ips" {
  for_each = local.public_subnets_with_nat_gw # keys --> public subnet CIDRs

  vpc = true
  tags = (
    var.nat_gateway_elastic_ip_tags != null
    ? lookup(var.nat_gateway_elastic_ip_tags, each.value.cidr, null)
    : null
  )

  depends_on = [aws_internet_gateway.list]
}

######################################################################
