######################################################################
### EXAMPLE USAGE: AWS_Route53

/* As in any Terragrunt configuration, the inputs below can be
provided in a single standalone resource config, or may be broken up
across multiple resource configs and utilized with a combination of
include-blocks and/or the read_terragrunt_config() Terragrunt fn. */

#---------------------------------------------------------------------
### Dependencies

dependency "Foo_ALB" {
  config_path = "${get_terragrunt_dir()}/../Foo_ALB"
}

#---------------------------------------------------------------------
### Inputs

inputs = {
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
        dns_domain_name = dependency.Foo_ALB.outputs.dns_name
        zone_id         = dependency.Foo_ALB.outputs.zone_id
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
