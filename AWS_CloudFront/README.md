<div align="center">
  <h1>Fixit Cloud ☁️ Module: AWS CloudFront</h2>

Terraform module for defining an AWS CloudFront distribution with related resources.

</div>

<h2>Table of Contents</h2>

- [🛠️ Distribution Config Notes](#️-distribution-config-notes)
  - [Geographic Restrictions](#geographic-restrictions)
  - [Unsupported Configurations](#unsupported-configurations)
- [⚙️ Module Usage](#️-module-usage)
  - [Usage Examples](#usage-examples)
  - [Requirements](#requirements)
  - [Providers](#providers)
  - [Modules](#modules)
  - [Resources](#resources)
  - [Inputs](#inputs)
  - [Outputs](#outputs)
- [📝 License](#-license)
- [💬 Contact](#-contact)

## 🛠️ Distribution Config Notes

### Geographic Restrictions

When setting a distribution's geographic restrictions (see input `var.distribution.geo_restrictions`), the API only accepts [ISO 3166-1 alpha-2](https://www.iso.org/iso-3166-country-codes.html) country codes, a list of which is available [here](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2).

### Unsupported Configurations

This module does not support the following CloudFront-related configurations:

| Unsupported Config                             | Use this Instead                 | Will Support be Added in the Future? |
| :--------------------------------------------- | :------------------------------- | :----------------------------------: |
| Legacy Origin Access Identities for S3 origins | [Origin Access Controls][s3-oac] |                  No                  |
| AWS accounts as trusted signers                | [Trusted key groups][key-groups] |                  No                  |
| Field-level encryption                         | N/A                              |                 Yes                  |

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-start -->

---

## ⚙️ Module Usage

### Usage Examples

- Terragrunt: [view Terragrunt usage exmaple](examples/terragrunt.hcl)
- Terraform: &nbsp;[view vanilla Terraform usage exmaple](examples/terraform.tf)

### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | 1.3.2 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.34.0 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.34.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [aws_cloudfront_cache_policy.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_cache_policy) | resource |
| [aws_cloudfront_distribution.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_function.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_function) | resource |
| [aws_cloudfront_key_group.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_key_group) | resource |
| [aws_cloudfront_origin_access_control.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_control) | resource |
| [aws_cloudfront_origin_request_policy.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_request_policy) | resource |
| [aws_cloudfront_public_key.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_public_key) | resource |
| [aws_cloudfront_realtime_log_config.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_realtime_log_config) | resource |
| [aws_cloudfront_response_headers_policy.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_response_headers_policy) | resource |
| [aws_acm_certificate.map](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/acm_certificate) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_logging_config"></a> [access\_logging\_config](#input\_access\_logging\_config) | (Optional) Conifg object for access loggin. | <pre>object({<br>    bucket_url      = string<br>    log_prefix      = optional(string)<br>    include_cookies = optional(bool, false)<br>  })</pre> | `null` | no |
| <a name="input_cache_behaviors"></a> [cache\_behaviors](#input\_cache\_behaviors) | Ordered list of cache behavior config objects. The zero-index cache behavior<br>shall serve as the distribution's default cache behavior. "path\_pattern" is<br>required for all non-default cache behaviors, and ignored for the default<br>behavior.<br><br>The value of "cache\_policy", if provided, must be one of the cache policy name<br>keys provided in `var.cache_policies`. The value of "origin\_request\_policy", if<br>provided, must be one of the origin request policy name keys provided in `var.<br>origin_request_policies`. The value of "response\_headers\_policy", if provided, must<br>be one of the response header policy names provided in `var.response_headers_policies`.<br>"viewer\_protocol\_policy", if provided, must be one of "allow-all", "redirect-to-https",<br>or "https-only".<br><br>Lambda@Edge and CloudFront-Function associations are configured respectively via<br>the "lambda\_edge\_associations" and "cloudfront\_function\_associations" properties,<br>wherein the keys for the former must be ARNs of existing Lambda@Edge functions,<br>and the keys for the latter must be names of CloudFront-Functions included as keys<br>in `var.cloudfront_functions`. For both types of functions, "event\_type" must be<br>one of "viewer-request", "viewer-response", "origin-request", or "origin-response".<br><br>"trusted\_key\_groups", if provided, must be a list of 1+ names included as keys in<br>`var.trusted_key_groups`. "realtime\_log\_config", if present, must be set to one of<br>the name-keys provided in `var.realtime_log_configs`. | <pre>list(<br>    object({<br>      path_pattern            = optional(string) # required for non-default cache behaviors<br>      target_origin_id        = string<br>      allowed_methods         = list(string)<br>      cached_methods          = list(string)<br>      compress                = optional(bool, false)<br>      trusted_key_groups      = optional(list(string))<br>      realtime_log_config     = optional(string)<br>      cache_policy            = optional(string)<br>      origin_request_policy   = optional(string)<br>      response_headers_policy = optional(string)<br>      viewer_protocol_policy  = optional(string, "redirect-to-https") # can also be "allow-all" or "https-only"<br>      forwarded_values = optional(list(object({<br>        query_string            = bool<br>        query_string_cache_keys = optional(list(string))<br>        headers                 = optional(list(string))<br>        cookies = optional(object({<br>          forward           = optional(string, "all") # can also be "none" or "whitelist"<br>          whitelisted_names = optional(list(string))  # required when forward == "whitelist"<br>        }), { forward = "all" })<br>      })))<br>      lambda_edge_associations = optional(map(<br>        # map keys: Lambda@Edge function ARNs<br>        object({<br>          event_type   = string # "viewer-request", "viewer-response", "origin-request", or "origin-response"<br>          include_body = optional(bool, false)<br>        })<br>      ))<br>      cloudfront_function_associations = optional(map(<br>        # map keys: CloudFront Function names<br>        object({<br>          event_type = string # "viewer-request", "viewer-response", "origin-request", or "origin-response"<br>        })<br>      ))<br>      ttl = optional(object({<br>        min     = optional(number)<br>        default = optional(number)<br>        max     = optional(number)<br>      }), {})<br>    })<br>  )</pre> | n/a | yes |
| <a name="input_cache_policies"></a> [cache\_policies](#input\_cache\_policies) | (Optional) Map of cache policy names to config objects. "policy" includes config<br>properties which control what's included in the cache key and subsequently forwarded<br>to the origin. | <pre>map(<br>    # map keys: cache policy names<br>    object({<br>      comment = optional(string, "Managed by Terraform")<br>      ttl = object({<br>        min     = number<br>        default = optional(number)<br>        max     = optional(number)<br>      })<br>      policy = object({<br>        header_controls = object({<br>          include = string # none, whitelist<br>          headers = optional(list(string))<br>        })<br>        cookie_controls = object({<br>          include = string # none, whitelist, allExcept, all<br>          cookies = optional(list(string))<br>        })<br>        query_string_controls = object({<br>          include       = string # none, whitelist, allExcept, all<br>          query_strings = optional(list(string))<br>        })<br>        enable_accept_encoding = optional(object({<br>          brotli = optional(bool, false)<br>          gzip   = optional(bool, false)<br>        }), { brotli = false, gzip = false })<br>      })<br>    })<br>  )</pre> | `null` | no |
| <a name="input_cloudfront_functions"></a> [cloudfront\_functions](#input\_cloudfront\_functions) | (Optional) Map of CloudFront Function names to config objects. | <pre>map(<br>    # map keys: CloudFront Function names<br>    object({<br>      runtime = string<br>      code    = string # e.g., file("${path.module}/function.js")<br>      comment = optional(string, "Managed by Terraform")<br>      publish = optional(bool, true)<br>    })<br>  )</pre> | `null` | no |
| <a name="input_cname_aliases"></a> [cname\_aliases](#input\_cname\_aliases) | (Optional) List of CNAME aliases. | `list(string)` | `null` | no |
| <a name="input_comment"></a> [comment](#input\_comment) | (Optional) A comment attached to the distribution. | `string` | `"Managed by Terraform"` | no |
| <a name="input_custom_error_responses"></a> [custom\_error\_responses](#input\_custom\_error\_responses) | (Optional) Map of HTTP error codes to config objects for handling each respective error. | <pre>map(<br>    # map keys: HTTP error codes (e.g., "404")<br>    object({<br>      response_code         = optional(string)<br>      response_page_path    = optional(string) # e.g., "/custom_404.html"<br>      error_caching_min_ttl = optional(number)<br>    })<br>  )</pre> | `null` | no |
| <a name="input_default_root_object"></a> [default\_root\_object](#input\_default\_root\_object) | (Optional) The distribution's default root object (e.g., "index.html"). | `string` | `null` | no |
| <a name="input_distribution_enabled"></a> [distribution\_enabled](#input\_distribution\_enabled) | (Optional) Whether the distribution is enabled. | `bool` | `true` | no |
| <a name="input_distribution_tags"></a> [distribution\_tags](#input\_distribution\_tags) | (Optional) The distribution's tags. | `map(string)` | `null` | no |
| <a name="input_geo_restrictions"></a> [geo\_restrictions](#input\_geo\_restrictions) | (Optional) Config object for geographic restrictions. For "country\_codes", a list of<br>valid ISO country codes is available [here](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2). | <pre>object({<br>    type          = optional(string, "none") # can also be "whitelist" or "blacklist"<br>    country_codes = optional(list(string))<br>  })</pre> | <pre>{<br>  "type": "none"<br>}</pre> | no |
| <a name="input_http_version"></a> [http\_version](#input\_http\_version) | (Optional) The HTTP version used by the distribution; can be one of "http1.1", "http2" (default), "http2and3", or "http3". | `string` | `"http2"` | no |
| <a name="input_is_ipv6_enabled"></a> [is\_ipv6\_enabled](#input\_is\_ipv6\_enabled) | (Optional) Whether ipv6 is enabled for the distribution. | `bool` | `false` | no |
| <a name="input_origin_groups"></a> [origin\_groups](#input\_origin\_groups) | (Optional) Map of origin group IDs to origin group config objects. | <pre>map(object({<br>    # map keys: ORIGIN GROUP IDs (can be any valid identifier)<br>    primary_origin_id     = string<br>    failover_origin_id    = string<br>    failover_status_codes = list(number)<br>  }))</pre> | `null` | no |
| <a name="input_origin_request_policies"></a> [origin\_request\_policies](#input\_origin\_request\_policies) | (Optional) Map of origin request policy names to config objects. "policy" includes<br>config properties which control what's included in the origin request key and forwarded<br>to the origin. | <pre>map(<br>    # map keys: origin request policy names<br>    object({<br>      comment = optional(string, "Managed by Terraform")<br>      policy = object({<br>        header_controls = object({<br>          include = string # none, whitelist, allViewer, allViewerAndWhitelistCloudFront<br>          headers = optional(list(string))<br>        })<br>        cookie_controls = object({<br>          include = string # none, whitelist, all, cookies<br>          cookies = optional(list(string))<br>        })<br>        query_string_controls = object({<br>          include       = string # none, whitelist, all, query_strings<br>          query_strings = optional(list(string))<br>        })<br>      })<br>    })<br>  )</pre> | `null` | no |
| <a name="input_origins"></a> [origins](#input\_origins) | Map of origin domain names to origin config objects. "origin\_id" can be any<br>valid identifier, but a solid recommendation is to simply use the origin's<br>domain. | <pre>map(<br>    # map keys: ORIGIN DOMAIN NAMES<br>    object({<br>      origin_id           = string<br>      origin_path         = optional(string)<br>      connection_attempts = optional(number, 3)  # 1 - 3<br>      connection_timeout  = optional(number, 10) # 1 - 10<br>      custom_headers      = optional(map(string))<br>      custom_origin_config = optional(object({<br>        http_port         = optional(number, 80)<br>        https_port        = optional(number, 443)<br>        protocol_policy   = optional(string, "https-only")      # can also be "http-only" or "match-viewer"<br>        ssl_protocols     = optional(list(string), ["TLSv1.2"]) # can also include "SSLv3", "TLSv1", and/or "TLSv1.1"<br>        keepalive_timeout = optional(number, 60)<br>        read_timeout      = optional(number, 60)<br>      }))<br>      s3_origin_access_control_config = optional(object({<br>        name             = string # name of the OAC (recommendation: use the s3 domain)<br>        description      = optional(string, "")<br>        signing_behavior = optional(string, "always") # can also be "never" or "no-override"<br>      }))<br>      origin_shield = optional(object({<br>        enabled = optional(bool, true)<br>        region  = string<br>      }))<br>    })<br>  )</pre> | n/a | yes |
| <a name="input_price_class"></a> [price\_class](#input\_price\_class) | (Optional) The distribution's price class; can be one of "PriceClass\_100", "PriceClass\_200", or "PriceClass\_All" (default). | `string` | `"PriceClass_All"` | no |
| <a name="input_public_keys"></a> [public\_keys](#input\_public\_keys) | (Optional) Map of public key names to config objects. | <pre>map(<br>    # map keys: names of public keys<br>    object({<br>      encoded_key = string # file("public_key.pem")<br>      comment     = optional(string, "Managed by Terraform")<br>    })<br>  )</pre> | `null` | no |
| <a name="input_realtime_log_configs"></a> [realtime\_log\_configs](#input\_realtime\_log\_configs) | (Optional) Map of realtime-log-config names to config objects. | <pre>map(<br>    # map keys: realtime log config names (recommendation: use origin domain names)<br>    object({<br>      sampling_rate           = number # 1- 100<br>      fields                  = list(string)<br>      kinesis_stream_arn      = string<br>      kinesis_stream_role_arn = string<br>  }))</pre> | `null` | no |
| <a name="input_reponse_headers_policies"></a> [reponse\_headers\_policies](#input\_reponse\_headers\_policies) | (Optional) Map of response-headers policy names to config objects.<br><br>Security Headers Config<br>Within "xss\_protection", "xeport\_uri" can not be provided if "mode\_block" is true. | <pre>map(<br>    # map keys: response header policy names<br>    object({<br>      comment = optional(string, "Managed by Terraform")<br>      cors_config = optional(object({<br>        should_override_origin           = optional(bool, true)<br>        access_control_allow_credentials = optional(bool, true)<br>        access_control_max_age_sec       = optional(number)<br>        access_control_allow_headers     = list(string)<br>        access_control_allow_methods     = list(string) # GET | POST | OPTIONS | PUT | DELETE | HEAD | ALL<br>        access_control_allow_origins     = list(string)<br>        access_control_expose_headers    = optional(list(string))<br>      }))<br>      custom_headers_config = optional(map(<br>        # map keys: HTTP header names<br>        object({<br>          header_value           = string<br>          should_override_origin = optional(bool, true)<br>        })<br>      ))<br>      security_headers_config = optional(object({<br>        content_security_policy = optional(object({<br>          content_security_policy = string<br>          should_override_origin  = optional(bool, true)<br>        }))<br>        content_type_options = optional(object({<br>          should_override_origin = optional(bool, true)<br>        }))<br>        frame_options = optional(object({<br>          frame_option           = string # DENY | SAMEORIGIN<br>          should_override_origin = optional(bool, true)<br>        }))<br>        referrer_policy = optional(object({<br>          referrer_policy        = string # no-referrer | no-referrer-when-downgrade | origin | origin-when-cross-origin | same-origin | strict-origin | strict-origin-when-cross-origin | unsafe-url<br>          should_override_origin = optional(bool, true)<br>        }))<br>        strict_transport_security = optional(object({<br>          access_control_max_age_sec = number<br>          include_subdomains         = optional(bool, true)<br>          preload                    = optional(bool, true)<br>          should_override_origin     = optional(bool, true)<br>        }))<br>        xss_protection = optional(object({<br>          report_uri             = optional(string) # <-- don't provide if mode_block is true<br>          mode_block             = optional(bool, true)<br>          protection             = optional(bool, true)<br>          should_override_origin = optional(bool, true)<br>        }))<br>      }))<br>      server_timing_headers_config = optional(object({<br>        enabled       = optional(bool, true)<br>        sampling_rate = number # 0 - 100 (inclusive)<br>      }))<br>    })<br>  )</pre> | `null` | no |
| <a name="input_trusted_key_groups"></a> [trusted\_key\_groups](#input\_trusted\_key\_groups) | (Optional) Map of trusted key group names to config objects. All values in<br>"key\_names" must be provided as keys to `var.public_keys`. | <pre>map(<br>    # map keys: names of trusted key groups<br>    object({<br>      key_names = list(string)<br>      comment   = optional(string, "Managed by Terraform")<br>    })<br>  )</pre> | `null` | no |
| <a name="input_viewer_certificate"></a> [viewer\_certificate](#input\_viewer\_certificate) | (Optional) Config object for the SSL viewer certificate. The certificate must<br>be either an ACM certificate, an IAM certificate, or a CloudFront-default<br>certificate. An ACM certificate can be used by either providing the cert's ARN<br>to "acm\_certificate\_arn", or the ARN can be looked up if the related domain is<br>provided to "acm\_certificate\_domain" (if the data block returns more than one<br>cert, the most recent one is used).<br><br>If neither an ACM nor IAM certificate is provided for via their respective config<br>properties, the distribution will use the CloudFront-default certificate, in which<br>case "minimum\_protocol\_version" will be set to "TLSv1" as required by AWS. | <pre>object({<br>    acm_certificate_arn      = optional(string)<br>    acm_certificate_domain   = optional(string)<br>    iam_certificate_id       = optional(string)<br>    minimum_protocol_version = optional(string, "TLSv1.2_2021")<br>    ssl_support_method       = optional(string, "sni-only") # can also be "vip"<br>  })</pre> | `null` | no |
| <a name="input_waf_web_acl_id"></a> [waf\_web\_acl\_id](#input\_waf\_web\_acl\_id) | (Optional) The WAF Web ACL ID of the distribution. | `string` | `null` | no |
| <a name="input_wait_for_deployment"></a> [wait\_for\_deployment](#input\_wait\_for\_deployment) | (Optional) Whether to wait for the distribution status to change from 'InProgress' to 'Deployed'. | `bool` | `true` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_Cache_Policies"></a> [Cache\_Policies](#output\_Cache\_Policies) | Map of cache policy resource objects. |
| <a name="output_CloudFront_Functions"></a> [CloudFront\_Functions](#output\_CloudFront\_Functions) | Map of CloudFront Function resource objects. |
| <a name="output_Distribution"></a> [Distribution](#output\_Distribution) | The CloudFront distribution resource object. |
| <a name="output_OriginAccessControls"></a> [OriginAccessControls](#output\_OriginAccessControls) | Map of origin domain names to OAC resource objects. |
| <a name="output_Origin_Request_Policies"></a> [Origin\_Request\_Policies](#output\_Origin\_Request\_Policies) | Map of origin request policy resource objects. |
| <a name="output_Public_Keys"></a> [Public\_Keys](#output\_Public\_Keys) | Map of public key resource objects. |
| <a name="output_Realtime_Log_Configs"></a> [Realtime\_Log\_Configs](#output\_Realtime\_Log\_Configs) | Map of target-origin IDs to realtime log config resource objects. |
| <a name="output_Reponse_Headers_Policies"></a> [Reponse\_Headers\_Policies](#output\_Reponse\_Headers\_Policies) | Map of response-headers policy resource objects. |
| <a name="output_Trusted_Key_Groups"></a> [Trusted\_Key\_Groups](#output\_Trusted\_Key\_Groups) | Map of trusted key group resource objects. |

---

## 📝 License

All scripts and source code contained herein are for commercial use only by Nerdware, LLC.

See [LICENSE](/LICENSE) for more information.

<div align="center" style="margin-top:30px;">

## 💬 Contact

Trevor Anderson - [@TeeRevTweets](https://twitter.com/teerevtweets) - [Trevor@Nerdware.cloud](mailto:trevor@nerdware.cloud)

<a href="https://www.youtube.com/channel/UCguSCK_j1obMVXvv-DUS3ng">
<img src="../.github/assets/YouTube_icon_circle.svg" height="40" />
</a>
&nbsp;
<a href="https://www.linkedin.com/in/meet-trevor-anderson/">
<img src="../.github/assets/LinkedIn_icon_circle.svg" height="40" />
</a>
&nbsp;
<a href="https://twitter.com/TeeRevTweets">
<img src="../.github/assets/Twitter_icon_circle.svg" height="40" />
</a>
&nbsp;
<a href="mailto:trevor@nerdware.cloud">
<img src="../.github/assets/email_icon_circle.svg" height="40" />
</a>
<br><br>

<a href="https://daremightythings.co/">
<strong><i>Dare Mighty Things.</i></strong>
</a>

</div>

<!-- prettier-ignore-end -->
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- LINKS -->

[s3-oac]: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3.html
[key-groups]: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-trusted-signers.html#choosing-key-groups-or-AWS-accounts
