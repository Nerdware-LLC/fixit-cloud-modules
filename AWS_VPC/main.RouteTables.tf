######################################################################
### ROUTE TABLES
######################################################################
### Public Subnet Route Tables

locals {
  /* Group PUBLIC subnet IDs by route table. For subnets where "custom_route_table"
  is null, use the Subnet-Type default route table name.  */
  public_subnet_route_tables = {
    for cidr, public_subnet in lookup(local.subnets_by_type, "PUBLIC", {}) : coalesce(
      public_subnet.custom_route_table, # <-- Custom RT names
      "Public_Subnets_RouteTable"       # <-- Will be skipped if all PUBLIC subnets use custom RTs
    ) => public_subnet.id...
  }
}

resource "aws_route_table" "Public_Subnet_RouteTables" {
  for_each = local.public_subnet_route_tables # keys: public-subnet RT names

  vpc_id = aws_vpc.this.id
  tags   = try(var.route_tables[each.key].tags, null)

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = one(aws_internet_gateway.list).id
  }

  dynamic "route" {
    for_each = coalesce(try(var.route_tables[each.key].routes, {}), {})
    # try, bc each.key may not be a custom RT; coalesce, bc routes may be null.

    content {
      cidr_block                = route.key
      vpc_peering_connection_id = route.value.vpc_peering_connection_id # optional, may be null
    }
  }

  lifecycle {
    /* Ensure any route tables named in PUBLIC subnet "custom_route_table" values
    exist as a key in "var.route_tables".  */
    precondition {
      condition = alltrue([for cidr, subnet in var.subnets :
        subnet.custom_route_table == null || try(contains((keys(var.route_tables)), subnet.custom_route_table), false)
      ])
      error_message = "Public subnet \"custom_route_table\" values must match a custom route table named in the \"route_tables\" variable."
    }
  }
}

#---------------------------------------------------------------------
### Private Subnet Route Tables

# For private subnets
resource "aws_route_table" "Private_Subnet_RouteTables" {
  for_each = aws_nat_gateway.map # keys: CIDRs of NAT-containing public subnets

  vpc_id = aws_vpc.this.id
  tags   = try(var.route_tables[each.key].tags, null)

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = each.value.id
  }

  dynamic "route" {
    for_each = coalesce(try(var.route_tables[each.key].routes, {}), {})
    # try, bc each.key may not be a custom RT; coalesce, bc routes may be null.

    content {
      cidr_block                = route.key
      vpc_peering_connection_id = route.value.vpc_peering_connection_id # optional, may be null
    }
  }
}

#---------------------------------------------------------------------
### Intra-Only Subnets Route Table

resource "aws_route_table" "IntraOnly_Subnets_RouteTable" {
  count = can(local.subnets_by_type.INTRA-ONLY) ? 1 : 0

  vpc_id = aws_vpc.this.id
  tags   = try(var.route_tables.IntraOnly_Subnets_RouteTable.tags, null)
}

######################################################################
### SUBNET ROUTE TABLE ASSOCIATIONS

locals {

  # PUBLIC -----------------------------------------------------------

  # Map each PUBLIC subnet ID to the ID of its route table
  public_subnets_route_tables_map = {
    # The values from this transpose fn will always be lists with 1 RT name each
    for subnet_id, rt_name_list_of_one in transpose(local.public_subnet_route_tables) : subnet_id =>
    aws_route_table.Public_Subnet_RouteTables[one(rt_name_list_of_one)].id
    # one() returns RT name, which is our public-RT resources map key
  }

  # PRIVATE ----------------------------------------------------------

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

  # NAT route tables by AZ for implicit subnet assignment
  nat_route_tables_by_az = {
    for public_subnet_cidr, rt in aws_route_table.Private_Subnet_RouteTables
    : var.subnets[public_subnet_cidr].availability_zone => rt...
    # Get AZ from the public subnet which contains the RT's NAT gateway
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
  ]...) # <-- spread list of objects into merge() args

  # Merge IMPLICIT and EXPLICIT private subnet assignment objects
  private_subnets_route_tables_map = merge(
    local.implicit_private_subnets_route_tables_map,
    { # Explicit RT associations
      for cidr, private_subnet in lookup(local.subnets_by_type, "PRIVATE", {}) : private_subnet.id =>
      aws_route_table.Private_Subnet_RouteTables[private_subnet.custom_route_table].id
    }
  )

  # INTRA-ONLY -------------------------------------------------------

  intraOnly_subnets_route_table_map = {
    for cidr, intraOnly_subnet in lookup(local.subnets_by_type, "INTRA-ONLY", {})
    : intraOnly_subnet.id => one(aws_route_table.IntraOnly_Subnets_RouteTable).id
  }
}

#---------------------------------------------------------------------

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
