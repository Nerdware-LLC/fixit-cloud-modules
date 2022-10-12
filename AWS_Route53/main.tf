######################################################################
### AWS Route53

resource "aws_route53_zone" "map" {
  for_each = var.hosted_zones

  name              = each.key
  comment           = each.value.description
  delegation_set_id = each.value.delegation_set_id
  force_destroy     = each.value.should_force_destroy == true

  dynamic "vpc" {
    for_each = each.value.vpc != null ? [each.value.vpc] : []

    content {
      vpc_id     = vpc.value.vpc_id
      vpc_region = vpc.value.vpc_region
    }
  }

  tags = each.value.tags
}

#---------------------------------------------------------------------

resource "aws_route53_record" "map" {

  for_each = merge(
    # Convert var.records from list to map with unique keys
    { for record in var.records : "${record.name} ${record.type}" => record },
    # Setup NS records for hosted zones (disabled if "should_setup_ns_records"=false)
    {
      for domain, hosted_zone in aws_route53_zone.map : "${domain} NS" => {
        non_alias_records = {
          ttl    = 172800 # <-- 2 days
          values = hosted_zone.name_servers
        }
      }
      if var.hosted_zones[domain].should_setup_ns_records != false
    }
  )

  name    = split(" ", each.key)[0]
  type    = split(" ", each.key)[1]
  zone_id = aws_route53_zone.map[each.value.hosted_zone_domain].zone_id

  allow_overwrite                  = each.value.allow_overwrite
  set_identifier                   = each.value.set_identifier
  health_check_id                  = each.value.health_check_id # TODO Add in-module resource to provide config for this
  multivalue_answer_routing_policy = each.value.multivalue_answer_routing_policy

  # Non-Alias Record Properties
  ttl     = try(each.value.non_alias_records.ttl, null)
  records = try(each.value.non_alias_records.values, null)

  # Alias Record Properties
  dynamic "alias" {
    for_each = each.value.alias_record != null ? [each.value.alias_record] : []

    content {
      name                   = alias.value.dns_domain_name
      zone_id                = alias.value.zone_id
      evaluate_target_health = alias.value.evaluate_target_health
    }
  }

  dynamic "failover_routing_policy" {
    for_each = each.value.failover_routing_policy != null ? [each.value.failover_routing_policy] : []

    content {
      type = failover_routing_policy.value.type
    }
  }

  dynamic "geolocation_routing_policy" {
    for_each = each.value.geolocation_routing_policy != null ? [each.value.geolocation_routing_policy] : []

    content {
      continent   = geolocation_routing_policy.value.continent
      country     = geolocation_routing_policy.value.country
      subdivision = geolocation_routing_policy.value.subdivision
    }
  }

  dynamic "latency_routing_policy" {
    for_each = each.value.latency_routing_policy != null ? [each.value.latency_routing_policy] : []

    content {
      region = latency_routing_policy.value.aws_region
    }
  }

  dynamic "weighted_routing_policy" {
    for_each = each.value.weighted_routing_policy != null ? [each.value.weighted_routing_policy] : []

    content {
      weight = weighted_routing_policy.value.weight
    }
  }
}

#---------------------------------------------------------------------

resource "aws_route53_delegation_set" "map" {
  for_each = toset(var.delegation_sets)

  reference_name = each.value
}

######################################################################
