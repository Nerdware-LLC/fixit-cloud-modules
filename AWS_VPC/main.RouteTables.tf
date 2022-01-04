######################################################################
### ROUTE TABLES

locals {
  # Gather a list of distinct egress destinations
  egress_destinations = distinct([
    for subnet in values(var.subnets) : subnet.egress_destination
    if subnet.egress_destination != "NONE"
  ])

  # Map of all egress destinations with their CIDRs and tags
  egress_dest_configs = {
    for egress_dest in local.egress_destinations : egress_dest => {
      cidr = can(cidrsubnet(egress_dest, 4, 0)) ? egress_dest : "0.0.0.0/0"
      tags = lookup(var.route_table_tags, egress_dest, null)
    }
  }
}

resource "aws_route_table" "map" {
  for_each = local.egress_dest_configs

  vpc_id = aws_vpc.this.id
  tags   = each.value.tags
}

resource "aws_route" "internet_gateway_egress_routes" {
  count = lookup(aws_route_table.map, "INTERNET_GATEWAY", null) != null ? 1 : 0

  route_table_id         = aws_route_table.map["INTERNET_GATEWAY"].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = one(aws_internet_gateway.this).id
}

resource "aws_route" "nat_gateway_egress_routes" {
  count = lookup(aws_route_table.map, "NAT_GATEWAY", null) != null ? 1 : 0

  route_table_id         = aws_route_table.map["NAT_GATEWAY"].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = one(aws_nat_gateway.this).id
}

# TODO add aws_route resource & other resources for vpc-peering

#---------------------------------------------------------------------
### SUBNET ROUTE TABLE ASSOCIATIONS

resource "aws_route_table_association" "map" {
  for_each = {
    for cidr, subnet in var.subnets : cidr => subnet
    if subnet.egress_destination != "NONE"
  }

  route_table_id = aws_route_table.map["${each.value.egress_destination}"].id
  subnet_id      = aws_subnet.map[each.key].id
}

######################################################################
