######################################################################
### VPC Peering

resource "aws_vpc_peering_connection" "map" {
  for_each = var.peering_request_vpc_ids

  # Args for all peering connections
  vpc_id      = aws_vpc.this.id # requester
  peer_vpc_id = each.key        # accepter
  tags        = each.value.tags

  # Auto-accept if explicit acceptance is not required
  auto_accept = (
    each.value.peer_vpc_owner_account_id == null && each.value.peer_vpc_region == null
    ? true
    : false
  )

  # Args for when explicit acceptance is required
  peer_owner_id = each.value.peer_vpc_owner_account_id
  peer_region   = coalesce(each.value.peer_vpc_region, data.aws_region.current.name)
  /* Note: peer_owner_id automatically defaults to caller's own account
  if not provided, but peer_region does not default to caller's own region.
  Since peer_region MUST be specified if auto_accept is false (which would
  be the case if peer_owner_id is a different account), we use the aws_region
  data source to create the own-account default value behavior.  */
}

#---------------------------------------------------------------------
### Explicit Peering Connection Acceptance Config

resource "aws_vpc_peering_connection_accepter" "map" {
  for_each = var.peering_accept_connection_ids

  vpc_peering_connection_id = each.key
  auto_accept               = true
  tags                      = each.value.tags
}

#---------------------------------------------------------------------
### Peering Connection Options

resource "aws_vpc_peering_connection_options" "map" {
  # Result is map like { [peer_conn_ids] = { is_requester: bool, allow_dns: bool } }
  for_each = merge(
    { # First, peering connections where VPC is requester
      for peer_vpc_id, requester_peering in aws_vpc_peering_connection.map : requester_peering.id => {
        is_requester = true
        allow_dns    = var.peering_request_vpc_ids[peer_vpc_id].allow_remote_vpc_dns_resolution
      } if upper(requester_peering.accept_status) == "ACTIVE" # Options can't be set until the connection has been accepted
    },
    { # Then peering connections where VPC is accepter
      for peer_conn_id, accepter_peering in aws_vpc_peering_connection_accepter.map : peer_conn_id => {
        is_requester = false
        allow_dns    = var.peering_accept_connection_ids[peer_conn_id].allow_remote_vpc_dns_resolution
      } if upper(accepter_peering.accept_status) == "ACTIVE" # Options can't be set until the connection has been accepted
    }
  )

  vpc_peering_connection_id = each.key

  dynamic "requester" {
    for_each = each.value.is_requester == true ? [each.value] : []

    content {
      allow_remote_vpc_dns_resolution  = coalesce(requester.value.allow_dns, true)
      allow_classic_link_to_remote_vpc = false
      allow_vpc_to_remote_classic_link = false
    }
  }

  dynamic "accepter" {
    for_each = each.value.is_requester == false ? [each.value] : []

    content {
      allow_remote_vpc_dns_resolution  = coalesce(accepter.value.allow_dns, true)
      allow_classic_link_to_remote_vpc = false
      allow_vpc_to_remote_classic_link = false
    }
  }
}

######################################################################
