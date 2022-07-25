######################################################################
### App Mesh

resource "aws_appmesh_mesh" "this" {
  name = var.appmesh_mesh.name

  dynamic "spec" {
    for_each = (
      var.appmesh_mesh.should_allow_egress_traffic != null
      ? [{ should_allow_egress_traffic = var.appmesh_mesh.should_allow_egress_traffic }]
      : []
    )

    content {
      egress_filter {
        type = spec.value.should_allow_egress_traffic == true ? "ALLOW_ALL" : "DROP_ALL"
      }
    }
  }

  tags = var.appmesh_mesh.tags
}

#---------------------------------------------------------------------
### AppMesh Services

resource "aws_appmesh_virtual_service" "map" {
  for_each = var.appmesh_services

  name      = each.key
  mesh_name = aws_appmesh_mesh.this.id

  spec {
    provider {

      dynamic "virtual_node" {
        for_each = each.value.provider_type == "NODE" ? [each.value.provider_name] : []

        content {
          virtual_node_name = virtual_node.value
        }
      }

      dynamic "virtual_router" {
        for_each = each.value.provider_type == "ROUTER" ? [each.value.provider_name] : []

        content {
          virtual_router_name = virtual_router.value
        }
      }
    }
  }
}

#---------------------------------------------------------------------
### AppMesh Nodes

resource "aws_appmesh_virtual_node" "map" {
  for_each = var.appmesh_nodes

  name      = each.key
  mesh_name = aws_appmesh_mesh.this.id

  spec {

    # How nodes identify/communicate with other nodes
    service_discovery {

      dynamic "aws_cloud_map" {
        for_each = each.value.cloud_map_config != null ? [each.value.cloud_map_config] : []

        content {
          attributes = {
            stack = aws_cloud_map.value.stack
          }

          service_name   = aws_cloud_map.value.service_name
          namespace_name = aws_service_discovery_private_dns_namespace.this.name
        }
      }

      dynamic "dns" {
        for_each = (
          each.value.service_dns_hostname != null
          ? [each.value.service_dns_hostname]
          : []
        )

        content {
          hostname = each.value.service_dns_hostname
        }
      }
    }

    # Node: INBOUND traffic from other nodes or gateways
    listener {
      dynamic "port_mapping" {
        for_each = each.value.port_mappings

        content {
          port     = port_mapping.value.port
          protocol = port_mapping.value.protocol
        }
      }
    }

    # Node: OUTBOUND traffic to service
    backend {
      virtual_service {
        virtual_service_name = each.value.service_name
      }
    }

    # TODO implement Node healthchecks
  }
}

#---------------------------------------------------------------------
### AppMesh Routers

resource "aws_appmesh_virtual_router" "map" {
  for_each = var.appmesh_routers

  name      = each.key
  mesh_name = aws_appmesh_mesh.this.id

  spec {
    listener {
      port_mapping {
        port     = each.value.port
        protocol = each.value.protocol
      }
    }
  }

  tags = each.value.tags
}

#---------------------------------------------------------------------
### AppMesh Routes

# TODO Finish aws_appmesh_route resouce.
resource "aws_appmesh_route" "map" {
  for_each = var.appmesh_routes

  name                = each.key
  mesh_name           = aws_appmesh_mesh.this.id
  virtual_router_name = each.value.virtual_router_name

  spec {

    # TODO ensure all routes are configured with a retry policy!

    # HTTP ROUTE
    dynamic "http_route" {
      for_each = each.value.type == "http_route" ? [each.value.spec] : []

      content {
        match {

        }

        action {

        }
      }
    }

    # HTTP2 ROUTE
    dynamic "http2_route" {
      for_each = each.value.type == "http2_route" ? [each.value.spec] : []

      content {
        match {

        }

        action {

        }
      }
    }

    # gRPC ROUTE
    dynamic "grpc_route" {
      for_each = each.value.type == "grpc_route" ? [each.value.spec] : []

      content {
        match {

        }

        action {

        }
      }
    }

    # TCP ROUTE
    dynamic "tcp_route" {
      for_each = each.value.type == "tcp_route" ? [each.value.spec] : []

      content {
        action {

        }
      }
    }
  }

  tags = each.value.tags
}

######################################################################
