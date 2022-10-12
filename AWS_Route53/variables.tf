######################################################################
### INPUT VARIABLES

variable "hosted_zones" {
  description = <<-EOF
  Map of domain names to Route53 hosted zone config objects. To create
  a private hosted zone, you must provide one of either "vpc_association"
  or "delegation_set". Unless "should_setup_ns_records" is set to false,
  each hosted zones name servers will be setup as NS record resources.
  EOF

  type = map(
    # map keys: domain names
    object({
      description       = optional(string, "Managed by Terraform")
      delegation_set_id = optional(string)
      vpc_association = optional(object({
        vpc_id     = string
        vpc_region = optional(string)
      }))
      should_force_destroy    = optional(bool, false)
      should_setup_ns_records = optional(bool, true)
      tags                    = optional(map(string))
    })
  )
}

#---------------------------------------------------------------------

variable "records" {
  description = <<-EOF
  List of DNS resource record config objects. "hosted_zone_domain" values
  must be present as keys in the `var.hosted_zones` input object. "type" must
  be one of A, AAAA, CAA, CNAME, DS, MX, NAPTR, NS, PTR, SOA, SPF, SRV or TXT.
  One of either "non_alias_records" or "alias_record" must be provided. Only
  1 type of routing policy may be provided.
  EOF

  type = list(
    object({
      hosted_zone_domain = string # must be a key in var.hosted_zones
      name               = string # e.g., "foo.example.com"
      type               = string
      allow_overwrite    = optional(bool, true)
      set_identifier     = optional(string)
      health_check_id    = optional(string)
      non_alias_records = optional(object({
        ttl    = number
        values = list(string)
      }))
      alias_record = optional(object({
        dns_domain_name        = string
        zone_id                = string
        evaluate_target_health = optional(bool, true)
      }))
      failover_routing_policy = optional(object({
        type = string # PRIMARY or SECONDARY
      }))
      geolocation_routing_policy = optional(object({
        continent   = optional(string)
        country     = optional(string)
        subdivision = optional(string)
      }))
      latency_routing_policy = optional(object({
        aws_region = string
      }))
      weighted_routing_policy = optional(object({
        weight = number
      }))
      multivalue_routing_policy = optional(bool, false)
    })
  )
}

#---------------------------------------------------------------------

variable "delegation_sets" {
  description = "List of delegation set names."
  type        = list(string)
}

######################################################################
