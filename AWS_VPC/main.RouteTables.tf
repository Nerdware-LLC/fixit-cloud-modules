######################################################################
### ROUTE TABLES

resource "aws_route_table" "map" {
  for_each = toset([ # Note: set --> no dupes; same as distinct() fn here.
    for subnet in values(var.subnets) : subnet.egress_destination
    if subnet.egress_destination != "NONE"
  ])

  vpc_id = aws_vpc.this.id
  tags   = lookup(var.route_table_tags, each.key, null)
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

# TODO add aws_route resource & other resources for vpc-peering (CIDR will equal the key/egress_dest)

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
