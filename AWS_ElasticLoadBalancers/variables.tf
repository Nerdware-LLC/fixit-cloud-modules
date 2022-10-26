######################################################################
### INPUT VARIABLES

variable "load_balancers" {
  description = <<-EOF
  Map of load balancer names to config objects. "type" must be either
  "application", "network", or "gateway". "alb_should_enable_http2" is
  only applicable to Application LBs. "nlb_enable_cross_zone_load_balancing"
  is only applicable to Network LBs.
  EOF

  type = map(
    # map keys: load balancer names
    object({
      type         = string
      is_internal  = optional(bool, false)
      is_dualstack = optional(bool, false)
      subnets = optional(map(
        # map keys: subnet names
        object({
          subnet_id                = string
          elastic_ip_allocation_id = optional(string)
          private_ipv4_address     = optional(string)
          ipv6_address             = optional(string)
        })
      ))
      alb_security_group_ids               = optional(list(string))
      alb_should_enable_http2              = optional(bool, true)
      nlb_enable_cross_zone_load_balancing = optional(bool, false)
      enable_deletion_protection           = optional(bool, true)
      desync_mitigation_mode               = optional(string, "defensive")
      idle_timeout_seconds                 = optional(number, 60)
      access_logging = optional(object({
        s3_bucket_name = string
        log_prefix     = optional(string)
        is_enabled     = optional(bool, true)
      }))
      tags = optional(map(string))
    })
  )
}

#---------------------------------------------------------------------

variable "listeners" {
  description = <<-EOF
  Map of arbitrary LB listener names to config objects. LB listeners do not
  have names in AWS, but the provided names are used internally by this module
  to properly identify listeners and their associated parameters.
  "load_balancer_name" must exist as a key within var.load_balancers.

  Within "actions", "type" must be one of "forward", "redirect", or "fixed-response".
  Each listener must have at least 1 action where "is_default_action" is true.
  Support for auth-related types "authenticate-cognito" and "authenticate-oidc" will
  be added in the future. Each default action object is configured using the property
  which matches its type. Default actions can not have "conditions".
  EOF

  type = map(
    # map keys: arbitrary LB listener "names"
    object({
      load_balancer_name = string
      port               = optional(number)
      protocol           = optional(string)
      certificate_arn    = optional(string)
      certificate = optional(object({
        domain      = string
        type        = optional(string, "AMAZON_ISSUED")
        status      = optional(string, "ISSUED")
        most_recent = optional(bool, true)
      }))
      ssl_policy      = optional(string) # Required for protocols HTTPS or TLS
      tls_alpn_policy = optional(string)
      tags            = optional(map(string))
      actions = list(object({
        # TODO Add support for listeners of type "authenticate-oidc" and "authenticate-cognito"
        type              = string # "forward", "redirect", or "fixed-response"
        is_default_action = optional(bool, false)
        priority          = optional(number) # Required if >1 actions
        forward = optional(object({
          target_groups = list(object({
            name   = string           # name must match a key in var.target_groups
            weight = optional(number) # 0 to 999
          }))
          stickiness = optional(object({
            duration = number # 1 - 604800 seconds (7 days)
            enabled  = optional(bool, false)
          }))
        }))
        redirect = optional(object({
          status_code = string # "HTTP_301" (permanent), or "HTTP_302" (temporary)
          host        = optional(string)
          port        = optional(string)
          path        = optional(string)
          protocol    = optional(string)
          query       = optional(string)
        }))
        fixed_response = optional(object({
          content_type = string # "text/plain", "text/css", "text/html", "application/javascript", or "application/json"
          message_body = optional(string)
          status_code  = optional(string)
        }))
        # Conditions only apply to non-default actions
        conditions = optional(list(object({
          source_ips           = optional(list(string))
          host_header_values   = optional(list(string))
          http_request_methods = optional(list(string))
          path_patterns        = optional(list(string))
          http_headers = optional(list(object({
            http_header_name = string
            values           = list(string)
          })))
          query_strings = optional(list(object({
            key   = optional(string)
            value = string
          })))
        })))
      }))
    })
  )
}

#---------------------------------------------------------------------

variable "target_groups" {
  description = <<-EOF
  Map of ELB Target Group names to config objects. "target_type" must be one
  of "instance", "ip", "lambda", or "alb". For non-Lambda targets, "port" and
  "protocol" must be provided; "protocol" must be one of GENEVE, HTTP, HTTPS,
  TCP, TCP_UDP, TLS, or UDP. If "protocol" is HTTP or HTTPS, you must provide
  "protocol_version", which must be one of HTTP1, HTTP2, or GRPC.

  To register targets to a target group, specify "targets" (note: ECS Services
  can be configured to handle registration of its containers with an ALB, don't
  manually register such containers).
  EOF

  type = map(
    # map keys: target group names
    object({
      target_type                        = string           # instance/ip/lambda/alb
      port                               = optional(number) # not required for lambda
      protocol                           = optional(string) # not required for lambda
      protocol_version                   = optional(string) # required for HTTP/HTTPS protocols
      ip_address_type                    = optional(string) # required for ip types, "ipv4" or "ipv6"
      vpc_id                             = optional(string)
      slow_start_warmup_seconds          = optional(number, 0)
      load_balancing_algorithm_type      = optional(string, "round_robin") # can also be "least_outstanding_requests"
      lambda_multi_value_headers_enabled = optional(bool, false)           # applies to lambda only
      health_check = optional(object({
        is_enabled          = optional(bool, true)
        healthy_threshold   = optional(number, 3)
        unhealthy_threshold = optional(number)
        interval            = optional(number, 30)
        matcher             = optional(string)
        path                = optional(string)
        port                = optional(string, "traffic-port")
        protocol            = optional(string, "HTTP")
        timeout             = optional(number)
      }))
      targets = optional(list(object({
        id                = string
        port              = optional(number)
        availability_zone = optional(number)
      })))
      tags = optional(map(string))
    })
  )
}

######################################################################
