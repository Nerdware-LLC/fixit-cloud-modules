######################################################################
### EXAMPLE USAGE: AWS_CloudFront

/* As in any Terragrunt configuration, the inputs below can be
provided in a single standalone resource config, or may be broken up
across multiple resource configs and utilized with a combination of
include-blocks and/or the read_terragrunt_config() Terragrunt fn. */

#---------------------------------------------------------------------
### Dependencies

dependency "Foo_LambdaEdge_Fn" {
  config_path = "${get_terragrunt_dir()}/../Foo_LambdaEdge_Fn"
}

#---------------------------------------------------------------------
### Inputs

inputs = {

  distribution_enabled = true

  cname_aliases = ["mysite.example.com", "yoursite.example.com"]

  default_root_object = "index.html"

  origins = {
    "example-bucket-origin.s3.us-east-2.amazonaws.com" = {
      # Keys for `var.origins` = origin domain names

      origin_id = "example-bucket-origin.s3.us-east-2.amazonaws.com" # <-- Does not have to be the domain name, but it simplifies origin management.

      s3_origin_access_control_config = {
        name = "example-bucket-origin.s3.us-east-2.amazonaws.com" # <-- Again, any valid ID works here, but I recommend using the domain.
      }
    }
  }

  viewer_certificate = {
    acm_certificate_domain = "example.com"
  }

  cache_behaviors = [
    # The index-0 cache behavior serves as the distribution's default cache behavior
    {
      target_origin_id        = "example-bucket-origin.s3.us-east-2.amazonaws.com"
      allowed_methods         = ["HEAD", "OPTIONS", "GET", "PUT", "POST", "PATCH", "DELETE"]
      cached_methods          = ["HEAD", "GET"]
      cache_policy            = "example_bucket_origin_cache_policy"   # <-- must be a key in `var.cache_policies` (below)
      origin_request_policy   = "example_bucket_origin_request_policy" # <-- must be a key in `var.origin_request_policies` (below)
      response_headers_policy = "Foo_Response_Headers_Policy"          # <-- must be a key in `var.response_headers_policies` (below)
      lambda_edge_associations = {
        dependency.Foo_LambdaEdge_Fn.outputs.Function.arn = {
          event_type   = "origin-response"
          include_body = true
        }
      }
      ttl = {
        min     = 0
        default = 3600
        max     = 86400
      }
    }
  ]

  cache_policies = {
    example_bucket_origin_cache_policy = {
      policy = {
        header_controls = {
          include = "none" # <-- don't use HTTP headers in the cache key
        }
        cookie_controls = {
          include = "allExcept"
          cookies = ["foo-cookie"] # <-- use all cookies except "foo-cookie" in the cache key
        }
        query_string_controls = {
          include       = "whitelist"
          query_strings = ["lang", "token"] # <-- only include these query-string params in the cache key
        }
        enable_accept_encoding = {
          gzip = true # <-- allow gzip-compressed content handling (but not brotli)
        }
      }
      ttl = {
        min = 0
      }
    }
  }

  /* All URL query strings, HTTP headers, and cookies that you include in the cache
  key (using a cache policy) are automatically included in origin requests. Use the
  origin request policy to specify the information that you want to include in origin
  requests, but NOT include in the cache key.  */
  origin_request_policies = {
    example_bucket_origin_request_policy = {
      policy = {
        header_controls = {
          include = "allViewer" # <-- forward all HTTP headers from the viewer request
        }
        cookie_controls = {
          include = "all" # <-- use all cookies in the origin request key
        }
        query_string_controls = {
          include       = "whitelist"
          query_strings = ["lang", "token"] # <-- only include these query-string params in the origin request key
        }
      }
    }
  }

  response_headers_policies = {
    Foo_Response_Headers_Policy = {
      content_security_policy = {
        content_security_policy = join("; ", [
          "default-src 'self' example.com",
          "base-uri 'self'",
          "block-all-mixed-content",
          "font-src 'self' https: data:",
          "frame-ancestors 'self'",
          "img-src 'self' data:",
          "object-src 'none'",
          "script-src 'self' example.com",
          "script-src-attr 'none'",
          "style-src 'self' https: 'unsafe-inline'",
          "upgrade-insecure-requests"
        ])
        # "should_override_origin" defaults to true for all properties in `var.response_headers_policies`
        should_override_origin = true
      }
      content_type_options = {
        # No values needed here - by including the property, CloudFront will set 'X-Content-Type-Options' to 'nosniff'
        should_override_origin = true
      }
      frame_options = {
        frame_option = "SAMEORIGIN"
      }
      referrer_policy = {
        referrer_policy = "no-referrer"
      }
      strict_transport_security = {
        access_control_max_age_sec = 15768000
        include_subdomains         = true
        preload                    = true
      }
      xss_protection = {
        mode_block = true
        protection = true
      }
    }
  }

  geo_restrictions = {
    type = "whitelist"
    # List of ISO country codes: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
    country_codes = [
      "US", # United States
      "CA", # Canada
      "MX", # Mexico
      "GB", # Great Britain
      "DE", # Germany
      "AU"  # Australia
    ]
  }
}

######################################################################
