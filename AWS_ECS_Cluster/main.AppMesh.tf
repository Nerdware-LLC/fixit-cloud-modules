######################################################################
### App Mesh

resource "aws_appmesh_mesh" "this" {
  name = var.app_mesh.name

  dynamic "spec" {
    for_each = (
      var.app_mesh.should_allow_egress_traffic != null
      ? [{ should_allow_egress_traffic = var.app_mesh.should_allow_egress_traffic }]
      : []
    )

    content {
      egress_filter {
        type = spec.value.should_allow_egress_traffic == true ? "ALLOW_ALL" : "DROP_ALL"
      }
    }
  }

  tags = var.app_mesh.tags
}

#---------------------------------------------------------------------
### AppMesh Services

resource "aws_appmesh_virtual_service" "map" {
  for_each = var.app_mesh_services

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
  for_each = var.app_mesh_nodes

  name      = each.key
  mesh_name = aws_appmesh_mesh.this.id

  spec {
    backend {
      virtual_service {
        virtual_service_name = each.value.service_name
      }
    }

    # listener {
    #   port_mapping {
    #     port     = 8080
    #     protocol = "http"
    #   }
    # }

    service_discovery {
      aws_cloud_map {
        attributes = {
          stack = "blue"
        }

        service_name   = "serviceb1"
        namespace_name = aws_service_discovery_http_namespace.example.name
      }

      dns {
        hostname = "serviceb.simpleapp.local"
      }
    }
  }
}

#---------------------------------------------------------------------
### AppMesh Routers

resource "aws_appmesh_virtual_router" "map" {
  for_each = var.app_mesh_routers

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
  for_each = var.app_mesh_routes

  name                = each.key
  mesh_name           = aws_appmesh_mesh.this.id
  virtual_router_name = each.value.virtual_router_name

  spec {

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
