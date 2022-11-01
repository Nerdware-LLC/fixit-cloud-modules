######################################################################
### INPUT VARIABLES

variable "distribution_enabled" {
  description = "(Optional) Whether the distribution is enabled."
  type        = bool
  default     = true
}

#---------------------------------------------------------------------

variable "distribution_tags" {
  description = "(Optional) The distribution's tags."
  type        = map(string)
  default     = null
}

#---------------------------------------------------------------------

variable "cname_aliases" {
  description = "(Optional) List of CNAME aliases."
  type        = list(string)
  default     = null
}

#---------------------------------------------------------------------

variable "is_ipv6_enabled" {
  description = "(Optional) Whether ipv6 is enabled for the distribution."
  type        = bool
  default     = false
}

#---------------------------------------------------------------------

variable "comment" {
  description = "(Optional) A comment attached to the distribution."
  type        = string
  default     = "Managed by Terraform"
}

#---------------------------------------------------------------------

variable "default_root_object" {
  description = "(Optional) The distribution's default root object (e.g., \"index.html\")."
  type        = string
  default     = null
}

#---------------------------------------------------------------------

variable "http_version" {
  description = "(Optional) The HTTP version used by the distribution; can be one of \"http1.1\", \"http2\" (default), \"http2and3\", or \"http3\"."
  type        = string
  default     = "http2"

  validation {
    condition     = contains(["http1.1", "http2", "http2and3", "http3"], var.http_version)
    error_message = "var.http_version, if provided, must be one of \"http1.1\", \"http2\", \"http2and3\", or \"http3\"."
  }
}

#---------------------------------------------------------------------

variable "price_class" {
  description = "(Optional) The distribution's price class; can be one of \"PriceClass_100\", \"PriceClass_200\", or \"PriceClass_All\" (default)."
  type        = string
  default     = "PriceClass_All"

  validation {
    condition     = contains(["PriceClass_100", "PriceClass_200", "PriceClass_All"], var.price_class)
    error_message = "var.price_class, if provided, must be one of \"PriceClass_100\", \"PriceClass_200\", or \"PriceClass_All\"."
  }
}

#---------------------------------------------------------------------

variable "waf_web_acl_id" {
  description = "(Optional) The WAF Web ACL ID of the distribution."
  type        = string
  default     = null
}

#---------------------------------------------------------------------

variable "wait_for_deployment" {
  description = "(Optional) Whether to wait for the distribution status to change from 'InProgress' to 'Deployed'."
  type        = bool
  default     = true
}

#---------------------------------------------------------------------

variable "origins" {
  description = <<-EOF
  Map of origin domain names to origin config objects. "origin_id" can be any
  valid identifier, but a solid recommendation is to simply use the origin's
  domain.
  EOF

  type = map(
    # map keys: ORIGIN DOMAIN NAMES
    object({
      origin_id           = string
      origin_path         = optional(string)
      connection_attempts = optional(number, 3)  # 1 - 3
      connection_timeout  = optional(number, 10) # 1 - 10
      custom_headers      = optional(map(string))
      custom_origin_config = optional(object({
        http_port         = optional(number, 80)
        https_port        = optional(number, 443)
        protocol_policy   = optional(string, "https-only")      # can also be "http-only" or "match-viewer"
        ssl_protocols     = optional(list(string), ["TLSv1.2"]) # can also include "SSLv3", "TLSv1", and/or "TLSv1.1"
        keepalive_timeout = optional(number, 60)
        read_timeout      = optional(number, 60)
      }))
      s3_origin_access_control_config = optional(object({
        name             = string # name of the OAC (recommendation: use the s3 domain)
        description      = optional(string, "")
        signing_behavior = optional(string, "always") # can also be "never" or "no-override"
      }))
      origin_shield = optional(object({
        enabled = optional(bool, true)
        region  = string
      }))
    })
  )
}

#---------------------------------------------------------------------

variable "origin_groups" {
  description = "(Optional) Map of origin group IDs to origin group config objects."
  type = map(object({
    # map keys: ORIGIN GROUP IDs (can be any valid identifier)
    primary_origin_id     = string
    failover_origin_id    = string
    failover_status_codes = list(number)
  }))
  default = null
}

#---------------------------------------------------------------------

variable "viewer_certificate" {
  description = <<-EOF
  (Optional) Config object for the SSL viewer certificate. The certificate must
  be either an ACM certificate, an IAM certificate, or a CloudFront-default
  certificate. An ACM certificate can be used by either providing the cert's ARN
  to "acm_certificate_arn", or the ARN can be looked up if the related domain is
  provided to "acm_certificate_domain" (if the data block returns more than one
  cert, the most recent one is used).

  If neither an ACM nor IAM certificate is provided for via their respective config
  properties, the distribution will use the CloudFront-default certificate, in which
  case "minimum_protocol_version" will be set to "TLSv1" as required by AWS.
  EOF

  type = object({
    acm_certificate_arn      = optional(string)
    acm_certificate_domain   = optional(string)
    iam_certificate_id       = optional(string)
    minimum_protocol_version = optional(string, "TLSv1.2_2021")
    ssl_support_method       = optional(string, "sni-only") # can also be "vip"
  })
  default = null
}

#---------------------------------------------------------------------

variable "cache_behaviors" {
  description = <<-EOF
  Ordered list of cache behavior config objects. The zero-index cache behavior
  shall serve as the distribution's default cache behavior. "path_pattern" is
  required for all non-default cache behaviors, and ignored for the default
  behavior.

  The value of "cache_policy", if provided, must be one of the cache policy name
  keys provided in `var.cache_policies`. The value of "origin_request_policy", if
  provided, must be one of the origin request policy name keys provided in `var.
  origin_request_policies`. The value of "response_headers_policy", if provided, must
  be one of the response header policy names provided in `var.response_headers_policies`.
  "viewer_protocol_policy", if provided, must be one of "allow-all", "redirect-to-https",
  or "https-only".

  Lambda@Edge and CloudFront-Function associations are configured respectively via
  the "lambda_edge_associations" and "cloudfront_function_associations" properties,
  wherein the keys for the former must be ARNs of existing Lambda@Edge functions,
  and the keys for the latter must be names of CloudFront-Functions included as keys
  in `var.cloudfront_functions`. For both types of functions, "event_type" must be
  one of "viewer-request", "viewer-response", "origin-request", or "origin-response".

  "trusted_key_groups", if provided, must be a list of 1+ names included as keys in
  `var.trusted_key_groups`. "realtime_log_config", if present, must be set to one of
  the name-keys provided in `var.realtime_log_configs`.
  EOF

  type = list(
    object({
      path_pattern            = optional(string) # required for non-default cache behaviors
      target_origin_id        = string
      allowed_methods         = list(string)
      cached_methods          = list(string)
      compress                = optional(bool, false)
      trusted_key_groups      = optional(list(string))
      realtime_log_config     = optional(string)
      cache_policy            = optional(string)
      origin_request_policy   = optional(string)
      response_headers_policy = optional(string)
      viewer_protocol_policy  = optional(string, "redirect-to-https") # can also be "allow-all" or "https-only"
      forwarded_values = optional(list(object({
        query_string            = bool
        query_string_cache_keys = optional(list(string))
        headers                 = optional(list(string))
        cookies = optional(object({
          forward           = optional(string, "all") # can also be "none" or "whitelist"
          whitelisted_names = optional(list(string))  # required when forward == "whitelist"
        }), { forward = "all" })
      })))
      lambda_edge_associations = optional(map(
        # map keys: Lambda@Edge function ARNs
        object({
          event_type   = string # "viewer-request", "viewer-response", "origin-request", or "origin-response"
          include_body = optional(bool, false)
        })
      ))
      cloudfront_function_associations = optional(map(
        # map keys: CloudFront Function names
        object({
          event_type = string # "viewer-request", "viewer-response", "origin-request", or "origin-response"
        })
      ))
      ttl = optional(object({
        min     = optional(number)
        default = optional(number)
        max     = optional(number)
      }), {})
    })
  )

  # Ensure 'forwarded_values' was not provided with cache_policy/origin_request_policy
  validation {
    condition = alltrue([
      for cache_behavior in var.cache_behaviors : cache_behavior.forwarded_values == null || (
        # If "forwarded_values" is NOT null, these 2 must both be null.
        cache_behavior.cache_policy == null && cache_behavior.origin_request_policy == null
      )
    ])
    error_message = "For all cache behaviors, \"forwarded_values\" must not be provided with \"cache_policy\"/\"origin_request_policy\"."
  }
}

#---------------------------------------------------------------------

variable "cache_policies" {
  description = <<-EOF
  (Optional) Map of cache policy names to config objects. "policy" includes config
  properties which control what's included in the cache key and subsequently forwarded
  to the origin.
  EOF

  type = map(
    # map keys: cache policy names
    object({
      comment = optional(string, "Managed by Terraform")
      ttl = object({
        min     = number
        default = optional(number)
        max     = optional(number)
      })
      policy = object({
        header_controls = object({
          include = string # none, whitelist
          headers = optional(list(string))
        })
        cookie_controls = object({
          include = string # none, whitelist, allExcept, all
          cookies = optional(list(string))
        })
        query_string_controls = object({
          include       = string # none, whitelist, allExcept, all
          query_strings = optional(list(string))
        })
        enable_accept_encoding = optional(object({
          brotli = optional(bool, false)
          gzip   = optional(bool, false)
        }), { brotli = false, gzip = false })
      })
    })
  )
  default = null
}

#---------------------------------------------------------------------

variable "origin_request_policies" {
  description = <<-EOF
  (Optional) Map of origin request policy names to config objects. "policy" includes
  config properties which control what's included in the origin request key and forwarded
  to the origin.
  EOF

  type = map(
    # map keys: origin request policy names
    object({
      comment = optional(string, "Managed by Terraform")
      policy = object({
        header_controls = object({
          include = string # none, whitelist, allViewer, allViewerAndWhitelistCloudFront
          headers = optional(list(string))
        })
        cookie_controls = object({
          include = string # none, whitelist, all, cookies
          cookies = optional(list(string))
        })
        query_string_controls = object({
          include       = string # none, whitelist, all, query_strings
          query_strings = optional(list(string))
        })
      })
    })
  )
  default = null
}

#---------------------------------------------------------------------

variable "reponse_headers_policies" {
  description = <<-EOF
  (Optional) Map of response-headers policy names to config objects.

  Security Headers Config
  Within "xss_protection", "xeport_uri" can not be provided if "mode_block" is true.
  EOF

  type = map(
    # map keys: response header policy names
    object({
      comment = optional(string, "Managed by Terraform")
      cors_config = optional(object({
        should_override_origin           = optional(bool, true)
        access_control_allow_credentials = optional(bool, true)
        access_control_max_age_sec       = optional(number)
        access_control_allow_headers     = list(string)
        access_control_allow_methods     = list(string) # GET | POST | OPTIONS | PUT | DELETE | HEAD | ALL
        access_control_allow_origins     = list(string)
        access_control_expose_headers    = optional(list(string))
      }))
      custom_headers_config = optional(map(
        # map keys: HTTP header names
        object({
          header_value           = string
          should_override_origin = optional(bool, true)
        })
      ))
      security_headers_config = optional(object({
        content_security_policy = optional(object({
          content_security_policy = string
          should_override_origin  = optional(bool, true)
        }))
        content_type_options = optional(object({
          should_override_origin = optional(bool, true)
        }))
        frame_options = optional(object({
          frame_option           = string # DENY | SAMEORIGIN
          should_override_origin = optional(bool, true)
        }))
        referrer_policy = optional(object({
          referrer_policy        = string # no-referrer | no-referrer-when-downgrade | origin | origin-when-cross-origin | same-origin | strict-origin | strict-origin-when-cross-origin | unsafe-url
          should_override_origin = optional(bool, true)
        }))
        strict_transport_security = optional(object({
          access_control_max_age_sec = number
          include_subdomains         = optional(bool, true)
          preload                    = optional(bool, true)
          should_override_origin     = optional(bool, true)
        }))
        xss_protection = optional(object({
          report_uri             = optional(string) # <-- don't provide if mode_block is true
          mode_block             = optional(bool, true)
          protection             = optional(bool, true)
          should_override_origin = optional(bool, true)
        }))
      }))
      server_timing_headers_config = optional(object({
        enabled       = optional(bool, true)
        sampling_rate = number # 0 - 100 (inclusive)
      }))
    })
  )
  default = null
}

#---------------------------------------------------------------------

variable "cloudfront_functions" {
  description = "(Optional) Map of CloudFront Function names to config objects."
  type = map(
    # map keys: CloudFront Function names
    object({
      runtime = string
      code    = string # e.g., file("${path.module}/function.js")
      comment = optional(string, "Managed by Terraform")
      publish = optional(bool, true)
    })
  )
  default = null
}

#---------------------------------------------------------------------

variable "trusted_key_groups" {
  description = <<-EOF
  (Optional) Map of trusted key group names to config objects. All values in
  "key_names" must be provided as keys to `var.public_keys`.
  EOF

  type = map(
    # map keys: names of trusted key groups
    object({
      key_names = list(string)
      comment   = optional(string, "Managed by Terraform")
    })
  )
  default = null
}

#---------------------------------------------------------------------

variable "public_keys" {
  description = "(Optional) Map of public key names to config objects."
  type = map(
    # map keys: names of public keys
    object({
      encoded_key = string # file("public_key.pem")
      comment     = optional(string, "Managed by Terraform")
    })
  )
  default = null
}

#---------------------------------------------------------------------

variable "realtime_log_configs" {
  description = "(Optional) Map of realtime-log-config names to config objects."
  type = map(
    # map keys: realtime log config names (recommendation: use origin domain names)
    object({
      sampling_rate           = number # 1- 100
      fields                  = list(string)
      kinesis_stream_arn      = string
      kinesis_stream_role_arn = string
  }))
  default = null
}

#---------------------------------------------------------------------

variable "custom_error_responses" {
  description = <<-EOF
  (Optional) Map of HTTP error codes to config objects for handling each respective error.
  EOF

  type = map(
    # map keys: HTTP error codes (e.g., "404")
    object({
      response_code         = optional(string)
      response_page_path    = optional(string) # e.g., "/custom_404.html"
      error_caching_min_ttl = optional(number)
    })
  )
  default = null
}

#---------------------------------------------------------------------

variable "geo_restrictions" {
  description = <<-EOF
  (Optional) Config object for geographic restrictions. For "country_codes", a list of
  valid ISO country codes is available [here](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2).
  EOF

  type = object({
    type          = optional(string, "none") # can also be "whitelist" or "blacklist"
    country_codes = optional(list(string))
  })
  default = {
    type = "none"
  }
}

#---------------------------------------------------------------------

variable "access_logging_config" {
  description = "(Optional) Conifg object for access loggin."
  type = object({
    bucket_url      = string
    log_prefix      = optional(string)
    include_cookies = optional(bool, false)
  })
  default = null
}

######################################################################
