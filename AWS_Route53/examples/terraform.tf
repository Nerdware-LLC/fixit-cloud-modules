######################################################################
### EXAMPLE USAGE: AWS_Route53

module "Foo_ALB" {
  /* dependency inputs */
}

module "AWS_CloudTrail" {
  source = "git@github.com:Nerdware-LLC/fixit-cloud-modules.git//AWS_Route53"

  hosted_zones = {
    "example.com" = {
      description = "Example public hosted zone"
    }
  }

  records = [
    # Simple alias record example:
    {
      hosted_zone_domain = "example.com"
      name               = "example.com"
      type               = "A"
      alias_record = {
        dns_domain_name = module.Foo_ALB.dns_name
        zone_id         = module.Foo_ALB.zone_id
      }
    },
    # CNAME examples with a routing policy:
    {
      hosted_zone_domain = "example.com"
      name               = "www-dev"
      type               = "CNAME"
      non_alias_records = {
        ttl    = 5
        values = ["dev.example.com"]
      }
      set_identifier = "dev" # <-- required when providing a routing policy
      weighted_routing_policy = {
        weight = 10
      }
    },
    {
      hosted_zone_domain = "example.com"
      name               = "www-live"
      type               = "CNAME"
      non_alias_records = {
        ttl    = 5
        values = ["live.example.com"]
      }
      set_identifier = "live" # <-- required when providing a routing policy
      weighted_routing_policy = {
        weight = 90
      }
    },
  ]
}

######################################################################
