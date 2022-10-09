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
        for_each = each.value.listener_port_mappings

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

resource "aws_appmesh_route" "map" {
  for_each = var.appmesh_routes

  name                = each.key
  mesh_name           = aws_appmesh_mesh.this.id
  virtual_router_name = each.value.virtual_router_name

  spec {

    # HTTP ROUTE
    dynamic "http_route" {
      for_each = each.value.type == "http_route" ? [each.value.spec] : []

      content {
        match {
          prefix = http_route.value.match.prefix
          method = http_route.value.match.method
          scheme = http_route.value.match.scheme

          # http_route.header
          dynamic "header" {
            for_each = http_route.value.header != null ? [http_route.value.header] : []

            content {
              name   = header.value.name
              invert = header.value.invert

              # http_route.header.match
              dynamic "match" {
                for_each = header.value.match != null ? [header.value.match] : []

                content {
                  exact  = match.value.exact
                  prefix = match.value.prefix
                  suffix = match.value.suffix
                  regex  = match.value.regex

                  # http_route.header.match.range
                  dynamic "range" {
                    for_each = match.value.range != null ? [match.value.range] : []

                    content {
                      start = range.value.start
                      end   = range.value.end
                    }
                  }
                }
              }
            }
          }
        }

        action {
          dynamic "weighted_target" {
            for_each = http_route.value.action_targets

            content {
              virtual_node = weighted_target.key
              weight       = weighted_target.value.weight
            }
          }
        }

        retry_policy {
          max_retries       = http_route.value.retry_policy.max_retries
          http_retry_events = http_route.value.retry_policy.http_retry_events
          tcp_retry_events  = http_route.value.retry_policy.tcp_retry_events

          per_retry_timeout {
            unit  = http_route.value.retry_policy.per_retry_timeout.unit
            value = http_route.value.retry_policy.per_retry_timeout.value
          }
        }

        dynamic "timeout" {
          for_each = http_route.value.idle_timeout != null ? [http_route.value.idle_timeout] : []

          content {
            idle {
              unit  = timeout.value.unit
              value = timeout.value.value
            }
          }
        }
      }
    }

    # HTTP2 ROUTE
    dynamic "http2_route" {
      for_each = each.value.type == "http2_route" ? [each.value.spec] : []

      content {
        match {
          prefix = http2_route.value.match.prefix
          method = http2_route.value.match.method
          scheme = http2_route.value.match.scheme

          # http2_route.header
          dynamic "header" {
            for_each = http2_route.value.header != null ? [http2_route.value.header] : []

            content {
              name   = header.value.name
              invert = header.value.invert

              # http2_route.header.match
              dynamic "match" {
                for_each = header.value.match != null ? [header.value.match] : []

                content {
                  exact  = match.value.exact
                  prefix = match.value.prefix
                  suffix = match.value.suffix
                  regex  = match.value.regex

                  # http2_route.header.match.range
                  dynamic "range" {
                    for_each = match.value.range != null ? [match.value.range] : []

                    content {
                      start = range.value.start
                      end   = range.value.end
                    }
                  }
                }
              }
            }
          }
        }

        action {
          dynamic "weighted_target" {
            for_each = http2_route.value.action_targets

            content {
              virtual_node = weighted_target.key
              weight       = weighted_target.value.weight
            }
          }
        }

        retry_policy {
          max_retries       = http2_route.value.retry_policy.max_retries
          http_retry_events = http2_route.value.retry_policy.http_retry_events
          tcp_retry_events  = http2_route.value.retry_policy.tcp_retry_events

          per_retry_timeout {
            unit  = http2_route.value.retry_policy.per_retry_timeout.unit
            value = http2_route.value.retry_policy.per_retry_timeout.value
          }
        }

        dynamic "timeout" {
          for_each = http2_route.value.idle_timeout != null ? [http_route2.value.idle_timeout] : []

          content {
            idle {
              unit  = timeout.value.unit
              value = timeout.value.value
            }
          }
        }
      }
    }

    # TODO Add support for TCP and gRPC route types
  }

  tags = each.value.tags
}

######################################################################
