######################################################################
### AWS CloudFront - CDN Distribution

locals {
  default_cache_behavior      = var.cache_behaviors[0]
  non_default_cache_behaviors = slice(var.cache_behaviors, 1, length(var.cache_behaviors))

  # For viewer_certificate, the default cert is used if the below properties are all null
  should_use_default_ssl_cert = alltrue([
    for viewer_cert_param in ["acm_certificate_arn", "acm_certificate_domain", "iam_certificate_id"]
    : var.viewer_certificate[viewer_cert_param] == null
  ])
}

# TFSec aws-cloudfront-enable-logging ignored to allow dev/sandbox env distributions to forgo access logging.
#tfsec:ignore:aws-cloudfront-enable-logging
resource "aws_cloudfront_distribution" "this" {
  enabled             = var.distribution_enabled
  aliases             = var.cname_aliases
  is_ipv6_enabled     = var.is_ipv6_enabled
  comment             = var.comment
  default_root_object = var.default_root_object
  http_version        = var.http_version
  price_class         = var.price_class
  web_acl_id          = var.waf_web_acl_id
  wait_for_deployment = var.wait_for_deployment
  tags                = var.distribution_tags

  # ORIGINS
  dynamic "origin" {
    for_each = var.origins # must have at least 1

    content {
      domain_name         = origin.key
      origin_id           = origin.value.origin_id
      origin_path         = origin.value.origin_path
      connection_attempts = origin.value.connection_attempts
      connection_timeout  = origin.value.connection_timeout

      origin_access_control_id = (
        origin.value.s3_origin_access_control_config != null
        ? aws_cloudfront_origin_access_control.map[origin.key].id
        : null
      )

      # ORIGIN: CUSTOM ORIGIN CONFIG
      dynamic "custom_origin_config" {
        for_each = origin.value.custom_origin_config != null ? [origin.value.custom_origin_config] : []

        content {
          http_port                = custom_origin_config.value.http_port         # default: 80
          https_port               = custom_origin_config.value.https_port        # default: 443
          origin_protocol_policy   = custom_origin_config.value.protocol_policy   # default: https-only
          origin_ssl_protocols     = custom_origin_config.value.ssl_protocols     # default: ["TLSv1.2"]
          origin_keepalive_timeout = custom_origin_config.value.keepalive_timeout # default: 60
          origin_read_timeout      = custom_origin_config.value.read_timeout      # default: 60
        }
      }

      # ORIGIN: CUSTOM HEADERS
      dynamic "custom_header" {
        for_each = origin.value.custom_headers != null ? origin.value.custom_headers : {}

        content {
          name  = custom_header.key
          value = custom_header.value
        }
      }

      # ORIGIN: ORIGIN SHIELD
      dynamic "origin_shield" {
        for_each = origin.value.origin_shield != null ? [origin.value.origin_shield] : []

        content {
          enabled              = origin_shield.value.enabled
          origin_shield_region = origin_shield.value.region
        }
      }
    }
  }

  # ORIGIN_GROUP
  dynamic "origin_group" {
    for_each = var.origin_groups != null ? var.origin_groups : {}

    content {
      origin_id = origin_group.key

      member {
        origin_id = origin_group.value.primary_origin_id
      }

      member {
        origin_id = origin_group.value.failover_origin_id
      }

      failover_criteria {
        status_codes = origin_group.value.failover_status_codes
      }
    }
  }

  viewer_certificate {
    acm_certificate_arn = try(
      data.aws_acm_certificate.map[var.viewer_certificate.acm_certificate_domain].arn,
      var.viewer_certificate.acm_certificate_arn
    )
    iam_certificate_id             = var.viewer_certificate.iam_certificate_id
    cloudfront_default_certificate = local.should_use_default_ssl_cert # <-- true if the above 2 are null, else false
    minimum_protocol_version       = local.should_use_default_ssl_cert ? "TLSv1" : var.viewer_certificate.minimum_protocol_version
    ssl_support_method             = var.viewer_certificate.ssl_support_method # default: "sni-only"
  }

  default_cache_behavior {
    target_origin_id = local.default_cache_behavior.target_origin_id
    allowed_methods  = local.default_cache_behavior.allowed_methods
    cached_methods   = local.default_cache_behavior.cached_methods
    compress         = local.default_cache_behavior.compress

    trusted_key_groups = (
      local.default_cache_behavior.trusted_key_groups != null
      ? [for key_grp in local.default_cache_behavior.trusted_key_groups : aws_cloudfront_key_group.map[key_grp].id]
      : []
    )

    # Note: "trusted_signers" intentionally unsupported since key groups offer
    # greater control and don't require broad account-level permissions.

    # TODO Add support for field level encryption configs (property 'field_level_encryption_config_id' goes here once ready)

    realtime_log_config_arn = (
      local.default_cache_behavior.realtime_log_config != null
      ? aws_cloudfront_realtime_log_config.map[local.default_cache_behavior.realtime_log_config].arn
      : null
    )

    # POLICIES
    cache_policy_id            = try(aws_cloudfront_cache_policy.map[local.default_cache_behavior.cache_policy].id, null)
    origin_request_policy_id   = try(aws_cloudfront_origin_request_policy.map[local.default_cache_behavior.origin_request_policy].id, null)
    response_headers_policy_id = try(aws_cloudfront_response_headers_policy.map[local.default_cache_behavior.response_headers_policy].id, null)
    viewer_protocol_policy     = local.default_cache_behavior.viewer_protocol_policy

    # TTL
    min_ttl     = local.default_cache_behavior.ttl.min
    default_ttl = local.default_cache_behavior.ttl.default
    max_ttl     = local.default_cache_behavior.ttl.max

    dynamic "forwarded_values" {
      /* If a cache policy or origin request policy are specified, we cannot include a
      `forwarded_values` block at all in the API request. This property-conflict issue
      is handled by a validation block in var.ordered_cache_behaviors.  */
      for_each = local.default_cache_behavior.forwarded_values != null ? [local.default_cache_behavior.forwarded_values] : []

      content {
        query_string            = forwarded_values.value.query_string
        query_string_cache_keys = forwarded_values.value.query_string_cache_keys
        headers                 = forwarded_values.value.headers

        cookies {
          forward           = forwarded_values.value.cookies.forward
          whitelisted_names = forwarded_values.value.cookies.whitelisted_names
        }
      }
    }

    dynamic "lambda_function_association" {
      for_each = local.default_cache_behavior.lambda_edge_associations != null ? local.default_cache_behavior.lambda_edge_associations : {}
      iterator = lambda_edge_fn

      content {
        lambda_arn   = lambda_edge_fn.key
        event_type   = lambda_edge_fn.value.event_type
        include_body = lambda_edge_fn.value.include_body
      }
    }

    dynamic "function_association" {
      for_each = local.default_cache_behavior.cloudfront_function_associations != null ? local.default_cache_behavior.cloudfront_function_associations : {}
      iterator = cloudfront_fn

      content {
        function_arn = aws_cloudfront_function.map[cloudfront_fn.key].arn
        event_type   = cloudfront_fn.value.event_type
      }
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = toset(local.non_default_cache_behaviors)

    content {
      # "path_pattern" is only used for non-default cache behaviors; the rest of the args are the same.
      path_pattern = ordered_cache_behavior.value.path_pattern

      target_origin_id = each.value.target_origin_id
      allowed_methods  = each.value.allowed_methods
      cached_methods   = each.value.cached_methods
      compress         = each.value.compress

      trusted_key_groups = (
        each.value.trusted_key_groups != null
        ? [for key_grp in each.value.trusted_key_groups : aws_cloudfront_key_group.map[key_grp].id]
        : []
      )

      # Note: "trusted_signers" intentionally unsupported since key groups offer
      # greater control and don't require broad account-level permissions.

      # TODO Add support for field level encryption configs (property 'field_level_encryption_config_id' goes here once ready)

      realtime_log_config_arn = (
        each.value.realtime_log_config != null
        ? aws_cloudfront_realtime_log_config.map[each.value.realtime_log_config].arn
        : null
      )

      # POLICIES
      cache_policy_id            = try(aws_cloudfront_cache_policy.map[each.value.cache_policy].id, null)
      origin_request_policy_id   = try(aws_cloudfront_origin_request_policy.map[each.value.origin_request_policy].id, null)
      response_headers_policy_id = try(aws_cloudfront_response_headers_policy.map[each.value.response_headers_policy].id, null)
      viewer_protocol_policy     = each.value.viewer_protocol_policy

      # TTL
      min_ttl     = each.value.ttl.min
      default_ttl = each.value.ttl.default
      max_ttl     = each.value.ttl.max

      dynamic "forwarded_values" {
        /* If a cache policy or origin request policy are specified, we cannot include a
        `forwarded_values` block at all in the API request. This property-conflict issue
        is handled by a validation block in var.ordered_cache_behaviors.  */
        for_each = each.value.forwarded_values != null ? [each.value.forwarded_values] : []

        content {
          query_string            = forwarded_values.value.query_string
          query_string_cache_keys = forwarded_values.value.query_string_cache_keys
          headers                 = forwarded_values.value.headers

          cookies {
            forward           = forwarded_values.value.cookies.forward
            whitelisted_names = forwarded_values.value.cookies.whitelisted_names
          }
        }
      }

      dynamic "lambda_function_association" {
        for_each = each.value.lambda_edge_associations != null ? each.value.lambda_edge_associations : {}
        iterator = lambda_edge_fn

        content {
          lambda_arn   = lambda_edge_fn.key
          event_type   = lambda_edge_fn.value.event_type
          include_body = lambda_edge_fn.value.include_body
        }
      }

      dynamic "function_association" {
        for_each = each.value.cloudfront_function_associations != null ? each.value.cloudfront_function_associations : {}
        iterator = cloudfront_fn

        content {
          function_arn = aws_cloudfront_function.map[cloudfront_fn.key].arn
          event_type   = cloudfront_fn.value.event_type
        }
      }
    }
  }

  dynamic "custom_error_response" {
    for_each = var.custom_error_responses

    content {
      error_code            = custom_error_response.key
      response_code         = custom_error_response.value.response_code
      response_page_path    = custom_error_response.value.response_page_path
      error_caching_min_ttl = custom_error_response.value.error_caching_min_ttl
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = var.geo_restrictions.type # default: "none"
      locations        = var.geo_restrictions.country_codes
    }
  }

  dynamic "logging_config" {
    for_each = var.access_logging_config != null ? [var.access_logging_config] : []

    content {
      bucket          = logging_config.value.bucket_url
      prefix          = logging_config.value.log_prefix
      include_cookies = logging_config.value.include_cookies # default: false
    }
  }

  depends_on = [
    aws_cloudfront_origin_access_control.map,
    aws_cloudfront_function.map,
    aws_cloudfront_realtime_log_config.map
  ]
}

######################################################################
