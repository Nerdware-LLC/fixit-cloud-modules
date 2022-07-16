######################################################################
### ROUTE TABLES

locals {

  /* PUBLIC and INTRA-ONLY subnets are associated with RTs in one of two ways:

  1) EXPLICIT Assignment - via the "route_table" subnet property
  2) STATIC Assignment   - uses fixed Subnet-Type RT

  If a PUBLIC or INTRA-ONLY subnet is not explicitly assigned to an RT, it's assigned
  to one of the arbitrarily-named base RTs below with routing configs that reflect the
  subnet type. For all PUBLIC subnet RTs, the default route ("0.0.0.0/0") must point
  to the VPC's internet gateway and therefore cannot be overridden. If any INTRA-ONLY
  subnets are present, one RT will be made for them which does not contain any routes
  by default.  */

  STATIC_SUBNET_TYPE_ROUTE_TABLES = {
    PUBLIC     = "Public_Subnets_RouteTable"
    INTRA-ONLY = "IntraOnly_Subnets_RouteTable"
  }

  /* PRIVATE subnets are associated with RTs in one of two ways:

  1) EXPLICIT Assignment - via the "route_table" subnet property
  2) DYNAMIC Assignment  - evenly distributed among same-AZ NAT-RTs

  DYNAMIC private subnets are evenly distributed among the NAT-RTs that are
  available within their AZ in order to spread out the load while avoiding cross-AZ
  NAT which incurs latency and undermines high-availability. An even distribution is
  achieved using an "index modulo list-length" formula, where "index" is the index
  of a subnet in a list of dynamic subnets within an AZ, and "list-length" is the
  number of RTs in the same AZ. Since a subnet's list index is an assignment factor,
  dynamic subnets must be separated into lists, organized by AZ.  */

  dynamic_private_subnets_by_az = {
    for cidr, private_subnet in lookup(local.subnets_by_type, "PRIVATE", {})
    : private_subnet.az => private_subnet... # <-- maps AZs to lists of subnets in each AZ
    if private_subnet.route_table == null    # <-- skip explicitly-set private subnets
  }

  /* Group NAT-connected route tables by AZ for dynamic subnet assignment. Like the
  NAT gateways themselves, these RTs will be internally identified by the CIDR of
  the public subnet which contains the related NAT gateway.  */
  nat_route_tables_by_az = {
    for nat_gw_public_subnet_cidr in keys(aws_nat_gateway.map)
    : local.subnet_resources[nat_gw_public_subnet_cidr].az => nat_gw_public_subnet_cidr...
  }

  # Map CIDRs of dynamic private subnets to RT names
  dynamic_private_subnet_route_tables = merge([
    # Create list of objects (1 obj per AZ), then spread list into merge() args
    for az, dynamic_subnets_in_az in local.dynamic_private_subnets_by_az : {
      for subnet_index, subnet in dynamic_subnets_in_az : subnet.cidr => (
        element(
          local.nat_route_tables_by_az[az],                       # <-- list of RTs in AZ
          subnet_index % length(local.nat_route_tables_by_az[az]) # <-- index mod list-length
        )
      )
    }
  ]...) # <-- spread list of objects into merge() fn args

  /* Normalize all subnet configs to use fallback RT if "route_table" is null.
  Note that this obj will be used to determine RT association resources.    */
  subnets_with_normalized_route_table = {
    for cidr, subnet in local.subnet_resources : cidr => merge(subnet, {
      route_table = (
        subnet.route_table != null
        ? subnet.route_table # <-- keep user-provided "route_table" if exists
        : try(               # <-- else assign fallback RT
          local.STATIC_SUBNET_TYPE_ROUTE_TABLES[subnet.type],
          local.dynamic_private_subnet_route_tables[cidr]
        )
      )
    })
  }

  # Provide each RT with the "type" of its subnets
  route_tables = {
    for rt_name, rt_subnets in {
      # Group RT subnets
      for cidr, normalized_subnet in local.subnets_with_normalized_route_table
      : normalized_subnet.route_table => normalized_subnet...
    }
    : rt_name => { subnet_type = one(rt_subnets).type } if length(rt_subnets) > 0
    # Loop inline obj, ensure we never create an RT with zero subnet associations
  }
}

resource "aws_route_table" "map" {
  for_each = local.route_tables

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
    for_each = each.value.subnet_type == "PUBLIC" ? ["0.0.0.0/0"] : []

    content {
      cidr_block = route.value
      gateway_id = one(aws_internet_gateway.list).id
    }
  }

  # PRIVATE subnet RTs default route
  dynamic "route" {
    for_each = each.value.subnet_type == "PRIVATE" ? ["0.0.0.0/0"] : []

    content {
      cidr_block = route.value
      /* The NAT gateway ID is obtained from aws_nat_gateway.map in one of two ways,
      depending on the nature of the private subnet's "route_table" value:

      1) In the case that the user merely wants to explicitly associate a private
      subnet with a particular NAT/NAT-RT, the value will be the CIDR of the subnet
      which contains the target NAT, in which case we can easily get the ID from
      aws_nat_gateway.map which uses those NAT-containing subnet CIDRs as its keys.

      2) If user wants two or more RTs which happen to have the same default route,
      "route_table" will be an arbitrary RT "name" string (example: two private
      subnets using same NAT, and user wants to add a vpc-peering route to only one
      of the two). In this case, in order to perform the lookup on aws_nat_gateway.map
      the CIDR must be obtained from the RT's config in var.route_tables.       */
      nat_gateway_id = try(
        aws_nat_gateway.map[each.key].id, # <-- [^1]
        lookup(                           # <-- [^2]
          aws_nat_gateway.map,
          var.route_tables[each.key].routes["0.0.0.0/0"].nat_gateway_subnet_cidr
        ).id
      )
    }
  }

  # All non-default routes
  dynamic "route" {
    for_each = {
      for route_cidr, route_config in try(coalesce(var.route_tables[each.key].routes, {}), {})
      : route_cidr => route_config if route_cidr != "0.0.0.0/0"
    }

    content {
      cidr_block = route.value
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

resource "aws_route_table_association" "map" {
  for_each = {
    for cidr, subnet in local.subnets_with_normalized_route_table
    : subnet.id => aws_route_table.map[subnet.route_table].id
  }

  subnet_id      = each.key
  route_table_id = each.value
}

######################################################################
