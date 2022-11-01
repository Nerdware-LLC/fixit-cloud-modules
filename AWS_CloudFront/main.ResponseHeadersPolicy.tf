######################################################################
### AWS CloudFront - Response Headers Policies

resource "aws_cloudfront_response_headers_policy" "map" {
  for_each = var.reponse_headers_policies != null ? var.reponse_headers_policies : {}

  name    = each.key
  comment = each.value.comment

  # CORS
  dynamic "cors_config" {
    for_each = var.reponse_headers_policies.cors_config != null ? [var.reponse_headers_policies.cors_config] : []

    content {
      origin_override                  = cors_config.value.should_override_origin           # default: true
      access_control_allow_credentials = cors_config.value.access_control_allow_credentials # default: true
      access_control_max_age_sec       = cors_config.value.access_control_max_age_sec

      access_control_allow_headers {
        items = cors_config.value.access_control_allow_headers
      }
      access_control_allow_methods {
        items = cors_config.value.access_control_allow_methods
      }
      access_control_allow_origins {
        items = cors_config.value.access_control_allow_origins
      }

      dynamic "access_control_expose_headers" {
        for_each = cors_config.value.access_control_expose_headers != null ? [1] : []

        content {
          items = cors_config.value.access_control_expose_headers
        }
      }
    }
  }

  # CUSTOM HEADERS
  dynamic "custom_headers_config" {
    for_each = var.reponse_headers_policies.custom_headers_config != null ? [1] : []

    content {
      dynamic "items" {
        for_each = var.reponse_headers_policies.custom_headers_config != null ? var.reponse_headers_policies.custom_headers_config : {}
        iterator = custom_header

        content {
          name     = custom_header.key
          value    = custom_header.value.header_value
          override = custom_header.value.should_override_origin
        }
      }
    }
  }

  # SECURITY HEADERS
  dynamic "security_headers_config" {
    for_each = var.reponse_headers_policies.security_headers_config != null ? [var.reponse_headers_policies.security_headers_config] : []

    content {
      # SECURITY HEADERS - CONTENT SECURITY POLICY
      dynamic "content_security_policy" {
        for_each = security_headers_config.value.content_security_policy != null ? [1] : []

        content {
          content_security_policy = security_headers_config.value.content_security_policy.content_security_policy
          override                = security_headers_config.value.content_security_policy.override
        }
      }

      # SECURITY HEADERS - CONTENT TYPE OPTIONS
      dynamic "content_type_options" {
        for_each = security_headers_config.value.content_type_options != null ? [1] : []

        content {
          override = security_headers_config.value.content_type_options.override
        }
      }

      # SECURITY HEADERS - FRAME OPTIONS
      dynamic "frame_options" {
        for_each = security_headers_config.value.frame_options != null ? [1] : []

        content {
          frame_options = security_headers_config.value.frame_options.frame_option # DENY or SAMEORIGIN
          override      = security_headers_config.value.frame_options.should_override_origin
        }
      }

      # SECURITY HEADERS - REFERRER POLICY
      dynamic "referrer_policy" {
        for_each = security_headers_config.value.referrer_policy != null ? [1] : []

        content {
          referrer_policy = security_headers_config.value.referrer_policy.referrer_policy
          override        = security_headers_config.value.referrer_policy.should_override_origin
        }
      }

      # SECURITY HEADERS - STRICT TRANSPORT SECURITY
      dynamic "strict_transport_security" {
        for_each = security_headers_config.value.strict_transport_security != null ? [1] : []

        content {
          access_control_max_age_sec = security_headers_config.value.strict_transport_security.access_control_max_age_sec
          include_subdomains         = security_headers_config.value.strict_transport_security.include_subdomains
          preload                    = security_headers_config.value.strict_transport_security.preload
          override                   = security_headers_config.value.strict_transport_security.should_override_origin
        }
      }

      # SECURITY HEADERS - XSS PROTECTION
      dynamic "xss_protection" {
        for_each = security_headers_config.value.xss_protection != null ? [1] : []

        content {
          report_uri = security_headers_config.value.xss_protection.report_uri
          mode_block = security_headers_config.value.xss_protection.mode_block
          protection = security_headers_config.value.xss_protection.protection
          override   = security_headers_config.value.xss_protection.should_override_origin
        }
      }
    }
  }

  # SERVER TIMING HEADERS
  dynamic "server_timing_headers_config" {
    for_each = var.reponse_headers_policies.server_timing_headers_config != null ? [var.reponse_headers_policies.server_timing_headers_config] : []

    content {
      enabled       = server_timing_headers_config.value.enabled
      sampling_rate = server_timing_headers_config.value.sampling_rate # 0 - 100 (inclusive)
    }
  }
}

######################################################################
