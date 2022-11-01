######################################################################
### AWS CloudFront - Origin Request Policies

resource "aws_cloudfront_origin_request_policy" "map" {
  for_each = var.origin_request_policies != null ? var.origin_request_policies : {}

  name    = each.key
  comment = each.value.comment

  # HEADERS
  headers_config {
    header_behavior = each.value.policy.header_controls.include # none, whitelist, allViewer, allViewerAndWhitelistCloudFront

    dynamic "headers" {
      for_each = each.value.policy.header_controls.headers != null ? [1] : []

      content {
        items = each.value.policy.header_controls.headers
      }
    }
  }

  # COOKIES
  cookies_config {
    cookie_behavior = each.value.policy.cookie_controls.include # none, whitelist, all, cookies

    dynamic "cookies" {
      for_each = each.value.policy.cookie_controls.cookies != null ? [1] : []

      content {
        items = each.value.policy.cookie_controls.cookies
      }
    }
  }

  # QUERY STRINGS
  query_strings_config {
    query_string_behavior = each.value.policy.query_string_controls.include # none, whitelist, all, query_strings

    dynamic "query_strings" {
      for_each = each.value.policy.query_string_controls.query_strings != null ? [1] : []

      content {
        items = each.value.policy.query_string_controls.query_strings
      }
    }
  }
}

######################################################################
