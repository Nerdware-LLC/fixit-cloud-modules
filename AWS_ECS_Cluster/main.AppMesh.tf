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

/* Due to an underlying resource implementation issue with aws_appmesh_route,
blocks "http_route" and "http2_route" within "spec" will BREAK the module-call
if they reference "each" in a dynamic block for_each statement. Therefore, at
this time the only way to allow for multiple route types with variable configs
as intended it to have entirely separate resource blocks for these different
route types. These resource blocks are then merged in OUTPUTS to achieve the
desired utility.  */

# HTTP ROUTES
resource "aws_appmesh_route" "http_routes_map" {
  for_each = {
    for route_name, route_config in var.appmesh_routes : route_name => route_config
    if route_config.type == "http"
  }

  name                = each.key
  mesh_name           = aws_appmesh_mesh.this.id
  virtual_router_name = each.value.virtual_router_name

  spec {
    http_route {
      /* If "http_route" is dynamic, the for_each that would go here would reference the
      outer "each" object, which at this time causes the entire module-call to fail.  */

      match {
        prefix = each.value.spec.match.prefix
        method = each.value.spec.match.method
        scheme = each.value.spec.match.scheme

        # http_route.header
        dynamic "header" {
          for_each = each.value.spec.match.header != null ? [each.value.spec.match.header] : []

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
          for_each = each.value.spec.action_targets

          content {
            virtual_node = weighted_target.key
            weight       = weighted_target.value.weight
          }
        }
      }

      retry_policy {
        max_retries       = each.value.spec.retry_policy.max_retries
        http_retry_events = each.value.spec.retry_policy.http_retry_events
        tcp_retry_events  = each.value.spec.retry_policy.tcp_retry_events

        per_retry_timeout {
          unit  = each.value.spec.retry_policy.per_retry_timeout.unit
          value = each.value.spec.retry_policy.per_retry_timeout.value
        }
      }

      dynamic "timeout" {
        for_each = each.value.spec.idle_timeout != null ? [each.value.spec.idle_timeout] : []

        content {
          idle {
            unit  = timeout.value.unit
            value = timeout.value.value
          }
        }
      }
    }
  }

  tags = each.value.tags
}

# HTTP2 ROUTES
resource "aws_appmesh_route" "http2_routes_map" {
  for_each = {
    for route_name, route_config in var.appmesh_routes : route_name => route_config
    if route_config.type == "http2"
  }

  name                = each.key
  mesh_name           = aws_appmesh_mesh.this.id
  virtual_router_name = each.value.virtual_router_name

  spec {
    http2_route {
      /* If "http2_route" is dynamic, the for_each that would go here would reference the
      outer "each" object, which at this time causes the entire module-call to fail.   */

      match {
        prefix = each.value.spec.match.prefix
        method = each.value.spec.match.method
        scheme = each.value.spec.match.scheme

        # http2_route.header
        dynamic "header" {
          for_each = each.value.spec.match.header != null ? [each.value.spec.match.header] : []

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
          for_each = each.value.spec.action_targets

          content {
            virtual_node = weighted_target.key
            weight       = weighted_target.value.weight
          }
        }
      }

      retry_policy {
        max_retries       = each.value.spec.retry_policy.max_retries
        http_retry_events = each.value.spec.retry_policy.http_retry_events
        tcp_retry_events  = each.value.spec.retry_policy.tcp_retry_events

        per_retry_timeout {
          unit  = each.value.spec.retry_policy.per_retry_timeout.unit
          value = each.value.spec.retry_policy.per_retry_timeout.value
        }
      }

      dynamic "timeout" {
        for_each = each.value.spec.idle_timeout != null ? [each.value.spec.idle_timeout] : []

        content {
          idle {
            unit  = timeout.value.unit
            value = timeout.value.value
          }
        }
      }
    }
  }

  tags = each.value.tags
}

# TODO Add support for TCP and gRPC route types

######################################################################
