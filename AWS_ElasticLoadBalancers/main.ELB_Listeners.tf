######################################################################
### AWS ELB Listeners

resource "aws_lb_listener" "map" {
  for_each = var.listeners

  load_balancer_arn = aws_lb.map[each.value.load_balancer_name].arn

  # Optional Listener Params:
  port            = each.value.port
  protocol        = each.value.protocol
  ssl_policy      = each.value.ssl_policy
  alpn_policy     = each.value.tls_alpn_policy
  certificate_arn = each.value.certificate_arn
  tags            = each.value.tags

  # DEFAULT ACTIONS:

  dynamic "default_action" {
    for_each = toset([for action in each.value.actions : action if action.is_default_action == true])

    content {
      type  = default_action.value.type
      order = default_action.value.priority

      # TYPE == "forward"
      dynamic "forward" {
        for_each = default_action.value.forward != null ? [default_action.value.forward] : []

        content {
          # (type == "forward").target_groups
          dynamic "target_group" {
            for_each = forward.value.target_groups

            content {
              arn    = aws_lb_target_group.map[target_group.value.name].arn
              weight = target_group.value.weight
            }
          }

          # (type == "forward").forward_stickiness
          dynamic "stickiness" {
            for_each = forward.value.stickiness != null ? [forward.value.stickiness] : []

            content {
              duration = stickiness.value.duration
              enabled  = stickiness.value.enabled
            }
          }
        }
      }

      # TYPE == "redirect"
      dynamic "redirect" {
        for_each = default_action.value.redirect != null ? [default_action.value.redirect] : []

        content {
          status_code = redirect.value.status_code
          host        = redirect.value.host
          port        = redirect.value.port
          path        = redirect.value.path
          protocol    = redirect.value.protocol
          query       = redirect.value.query
        }
      }

      # TYPE == "fixed_response"
      dynamic "fixed_response" {
        for_each = default_action.value.fixed_response != null ? [default_action.value.fixed_response] : []

        content {
          content_type = fixed_response.value.content_type
          message_body = fixed_response.value.message_body
          status_code  = fixed_response.value.status_code
        }
      }
    }
  }
}

#---------------------------------------------------------------------
### Listener Rules

resource "aws_lb_listener_rule" "map" {
  for_each = {
    # Filter out listeners which aren't configured with non-default actions
    for listener_name, listener in var.listeners : listener_name => listener
    if length([for action in listener.actions : action if action.is_default_action == false]) > 0
  }

  listener_arn = aws_lb_listener.map[each.key].arn

  # ACTIONS (non-default actions)

  dynamic "action" {
    for_each = toset([for action in each.value.actions : action if action.is_default_action != true])

    content {
      type = action.value.type

      # TYPE == "forward"
      dynamic "forward" {
        for_each = action.value.forward != null ? [action.value.forward] : []

        content {
          # (type == "forward").target_groups
          dynamic "target_group" {
            for_each = forward.value.target_groups

            content {
              arn    = aws_lb_target_group.map[target_group.value.name].arn
              weight = target_group.value.weight
            }
          }

          # (type == "forward").forward_stickiness
          dynamic "stickiness" {
            for_each = forward.value.stickiness != null ? [forward.value.stickiness] : []

            content {
              duration = stickiness.value.duration
              enabled  = stickiness.value.enabled
            }
          }
        }
      }

      # TYPE == "redirect"
      dynamic "redirect" {
        for_each = action.value.redirect != null ? [action.value.redirect] : []

        content {
          status_code = redirect.value.status_code
          host        = redirect.value.host
          port        = redirect.value.port
          path        = redirect.value.path
          protocol    = redirect.value.protocol
          query       = redirect.value.query
        }
      }

      # TYPE == "fixed_response"
      dynamic "fixed_response" {
        for_each = action.value.fixed_response != null ? [action.value.fixed_response] : []

        content {
          content_type = fixed_response.value.content_type
          message_body = fixed_response.value.message_body
          status_code  = fixed_response.value.status_code
        }
      }
    }
  }

  # CONDITIONS

  dynamic "condition" {
    for_each = each.value.conditions != null ? each.value.conditions : []

    content {
      # CONDITION: source_ip
      dynamic "source_ip" {
        for_each = condition.value.source_ips != null ? ["source_ip"] : []
        content {
          values = condition.value.source_ips
        }
      }

      # CONDITION: host_header (can have only 1 of these blocks)
      dynamic "host_header" {
        for_each = condition.value.host_header_values != null ? ["host_header"] : []
        content {
          values = condition.value.host_header_values
        }
      }

      # CONDITION: http_request_method (can have only 1 of these blocks)
      dynamic "http_request_method" {
        for_each = condition.value.http_request_methods != null ? ["http_request_method"] : []
        content {
          values = condition.value.http_request_methods
        }
      }

      # CONDITION: path_pattern (can have only 1 of these blocks)
      dynamic "path_pattern" {
        for_each = condition.value.path_patterns != null ? ["path_pattern"] : []
        content {
          values = condition.value.path_patterns
        }
      }

      # CONDITION: http_header (can have multiple of these blocks)
      dynamic "http_header" {
        for_each = condition.value.http_headers != null ? condition.value.http_headers : []
        content {
          http_header_name = http_header.value.http_header_name
          values           = http_header.value.values
        }
      }

      # CONDITION: query_string (can have multiple of these blocks)
      dynamic "query_string" {
        for_each = condition.value.query_strings != null ? condition.value.query_strings : []
        content {
          key   = query_string.value.key
          value = query_string.value.value
        }
      }
    }
  }
}

######################################################################
