######################################################################
### AWS CloudFront - Cache Policies

resource "aws_cloudfront_cache_policy" "map" {
  for_each = var.cache_policies != null ? var.cache_policies : {}

  name        = each.key
  comment     = each.value.comment
  min_ttl     = each.value.ttl.min
  default_ttl = each.value.ttl.default
  max_ttl     = each.value.ttl.max

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = each.value.policy.enable_accept_encoding.brotli # default: false
    enable_accept_encoding_gzip   = each.value.policy.enable_accept_encoding.gzip   # default: false

    # HEADERS
    headers_config {
      header_behavior = each.value.policy.header_controls.include # none, whitelist

      dynamic "headers" {
        for_each = each.value.policy.header_controls.headers != null ? [1] : []

        content {
          items = each.value.policy.header_controls.headers
        }
      }
    }

    # COOKIES
    cookies_config {
      cookie_behavior = each.value.policy.cookie_controls.include # none, whitelist, allExcept, all

      dynamic "cookies" {
        for_each = each.value.policy.cookie_controls.cookies != null ? [1] : []

        content {
          items = each.value.policy.cookie_controls.cookies
        }
      }
    }

    # QUERY STRINGS
    query_strings_config {
      query_string_behavior = each.value.policy.query_string_controls.include # none, whitelist, allExcept, all

      dynamic "query_strings" {
        for_each = each.value.policy.query_string_controls.query_strings != null ? [1] : []

        content {
          items = each.value.policy.query_string_controls.query_strings
        }
      }
    }
  }
}

######################################################################
