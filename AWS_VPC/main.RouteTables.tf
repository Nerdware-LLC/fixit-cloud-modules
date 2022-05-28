######################################################################
### ROUTE TABLES

locals {

  /* Map of PUBLIC subnet route table names to their respective routes. The
  creation of PUBLIC subnet RTs is determined by the "custom_route_table"
  properties of public subnets. If a public subnet isn't configured to use a
  custom RT, "Public_Subnets_RouteTable" is used as an arbitrary default name
  to represent a base RT with just the default and local routes. For all public
  subnet RTs, the default route ("0.0.0.0/0") must point to the VPC's internet
  gateway and therefore cannot be overridden.                               */
  public_subnet_route_tables = {
    for cidr, subnet in lookup(local.subnets_by_type, "PUBLIC", {}) : coalesce(
      subnet.custom_route_table,  # custom RTs
      "Public_Subnets_RouteTable" # Subnet-Type default RT name (arbitrary)
    ) =>
    merge(
      try(var.route_tables[subnet.custom_route_table].routes, {}),         # custom routes, if any
      { "0.0.0.0/0" = { gateway_id = one(aws_internet_gateway.list).id } } # default route
    )
  }

  /* Map of PRIVATE subnet route table names to their respective routes. The
  creation of PRIVATE subnet RTs is determined by the number of NAT gateways in
  the VPC (1:1). For each NAT-connected RT, the default route ("0.0.0.0/0") must
  point to the NAT gateway and therefore cannot be overridden. Any private subnets
  which aren't configured to use a specific NAT/NAT-RT will be evenly distributed
  among all available NAT-RTs in their availability zone.                      */
  private_subnet_route_tables = {
    for public_subnet_cidr, nat_gw in aws_nat_gateway.map : public_subnet_cidr => merge(
      try(var.route_tables[public_subnet_cidr].routes, {}), # custom routes, if any
      { "0.0.0.0/0" = { nat_gateway_id = nat_gw.id } }      # default route
    )
  }

  /* The creation of an INTRA-ONLY subnet route table is determined by whether or
  not the VPC contains any INTRA-ONLY subnets (max 1). If created, this route table
  will not contain any routes other than the non-configurable local route, thereby
  ensuring any associated subnets are only capable of intra-subnet net traffic.  */
  intraOnly_subnets_route_table = {
    for cidr, subnet in lookup(local.subnets_by_type, "INTRA-ONLY", {})
    : "IntraOnly_Subnets_RouteTable" => {} # No routes
  }
}

resource "aws_route_table" "map" {
  for_each = merge(
    local.public_subnet_route_tables,
    local.private_subnet_route_tables,
    local.intraOnly_subnets_route_table
  )

  vpc_id = aws_vpc.this.id
  tags   = try(var.route_tables[each.key].tags, null)

  /* dynamic "route" blocks cannot contain both "gateway_id" and "nat_gateway_id",
  even if set to null when unused. Therefore, three separate dynamic "route" blocks:
    - One which filters for default route with "gateway_id" (public subnet RTs)
    - One which filters for default route with "nat_gateway_id" (private subnet RTs)
    - One which filters out default routes and implements the rest
  */

  # PUBLIC subnet RTs default route
  dynamic "route" {
    for_each = {
      for route_cidr, route_config in each.value : route_cidr => route_config
      if route_cidr == "0.0.0.0/0" && can(route_config.gateway_id)
    }

    content {
      cidr_block = route.key
      gateway_id = route.value.gateway_id
    }
  }

  # PRIVATE subnet RTs default route
  dynamic "route" {
    for_each = {
      for route_cidr, route_config in each.value : route_cidr => route_config
      if route_cidr == "0.0.0.0/0" && can(route_config.nat_gateway_id)
    }

    content {
      cidr_block     = route.key
      nat_gateway_id = route.value.nat_gateway_id
    }
  }

  # All non-default routes
  dynamic "route" {
    for_each = {
      for route_cidr, route_config in each.value : route_cidr => route_config
      if route_cidr != "0.0.0.0/0"
    }

    content {
      cidr_block = route.key
      # Peering Connection Routes
      vpc_peering_connection_id = try(
        aws_vpc_peering_connection[route.value.peering_request_vpc_id].id, # for REQUESTER VPCs
        route.value.peering_accept_connection_id,                          # for ACCEPTER VPCs
        null
      )
    }
  }
}

#---------------------------------------------------------------------
### Subnet Route Table Associations

locals {

  # PUBLIC subnet RT associations
  public_subnets_route_tables_map = {
    for cidr, public_subnet in lookup(local.subnets_by_type, "PUBLIC", {}) : public_subnet.id =>
    aws_route_table.map[coalesce(public_subnet.custom_route_table, "Public_Subnets_RouteTable")].id
  }

  /* PRIVATE subnets are associated with RTs in one of two ways:

  1) EXPLICIT Assignment - via the "custom_route_table" subnet property
  2) IMPLICIT Assignment - subnets which aren't explicitly assigned

  IMPLICIT private subnets are evenly distributed among the NAT-RTs that are
  available within their AZ in order to spread out the load while avoiding cross-AZ
  NAT which incurs latency and undermines high-availability. An even distribution is
  achieved using an "index modulo list-length" formula, where "index" is the index
  of a subnet in a list of implicit subnets within an AZ, and "list-length" is the
  number of RTs in the same AZ. Since a subnet's list index is an assignment factor,
  implicit subnets must be separated into lists, organized by AZ.  */

  implicit_private_subnets_by_az = {
    for cidr, private_subnet in lookup(local.subnets_by_type, "PRIVATE", {})
    : private_subnet.az => private_subnet...     # <-- maps AZs to lists of subnets in each AZ
    if private_subnet.custom_route_table == null # <-- skip explicitly-set private subnets
  }

  # Group NAT-connected route tables by AZ for implicit subnet assignment.
  nat_route_tables_by_az = {
    /* NAT-RT "names" = the CIDR of the public subnet which contains the NAT, so instead
    of filtering aws_route_table.map, we can just use the keys of aws_nat_gateway.map */
    for public_subnet_cidr in keys(aws_nat_gateway.map) : local.subnet_resources[public_subnet_cidr].az =>
    aws_route_table.map[public_subnet_cidr]...
  }

  # Create list of objects which map implicit subnet IDs to RT IDs; spread list into merge fn args.
  implicit_private_subnets_route_tables_map = merge([
    # For each AZ, return an object which maps implicit subnet IDs to RT IDs
    for az, implicit_subnets_in_az in local.implicit_private_subnets_by_az : {
      for subnet_index, subnet in implicit_subnets_in_az : subnet.id => (
        element(
          local.nat_route_tables_by_az[az],                       # <-- list of RTs in AZ
          subnet_index % length(local.nat_route_tables_by_az[az]) # <-- index mod list-length
        ).id                                                      # <-- route table id
      )
    }
  ]...) # <-- spread list of objects into merge() fn args

  # Merge IMPLICIT and EXPLICIT private subnet assignment objects
  private_subnets_route_tables_map = merge(
    local.implicit_private_subnets_route_tables_map,
    { # Explicit RT associations
      for cidr, private_subnet in lookup(local.subnets_by_type, "PRIVATE", {}) : private_subnet.id =>
      try(aws_route_table.map[private_subnet.custom_route_table].id, null) # <-- try, so no null-lookups err
      if private_subnet.custom_route_table != null                         # <-- only explicitly-set private subnets
    }
  )

  # All INTRA-ONLY subnets are associated with "IntraOnly_Subnets_RouteTable"
  intraOnly_subnets_route_table_map = {
    for cidr, intraOnly_subnet in lookup(local.subnets_by_type, "INTRA-ONLY", {})
    : intraOnly_subnet.id => aws_route_table.map["IntraOnly_Subnets_RouteTable"].id
  }
}

resource "aws_route_table_association" "map" {
  # Now we simply merge the three subnet-RT assignment maps
  for_each = merge(
    local.public_subnets_route_tables_map,
    local.private_subnets_route_tables_map,
    local.intraOnly_subnets_route_table_map
  )

  subnet_id      = each.key
  route_table_id = each.value
}

######################################################################
