######################################################################
### Service Discovery

/* NOTE: The "private_dns_namespace" type allows both private DNS lookups
AND HTTP CloudMap API calls. Service discovery SERVICES are created/implemented
in the "AWS_ECS_Service" module (see "main.Service_Discovery.tf").  */

resource "aws_service_discovery_private_dns_namespace" "this" {
  name        = var.service_discovery_namespace.name
  description = var.service_discovery_namespace.description
  vpc         = var.service_discovery_namespace.vpc_id
  tags        = var.service_discovery_namespace.tags
}

#---------------------------------------------------------------------
### Service Discovery Service

resource "aws_service_discovery_service" "map" {
  for_each = var.service_discovery_services

  name = each.key

  # dns_config, dns_records, health_check_custom_config
  dynamic "dns_config" {
    for_each = each.value.dns_config != null ? [each.value.dns_config] : []

    content {
      namespace_id   = aws_service_discovery_private_dns_namespace.this.id
      routing_policy = dns_config.value.routing_policy

      dynamic "dns_records" {
        for_each = dns_config.value.dns_records

        content {
          type = dns_records.value.type
          ttl  = dns_records.value.ttl
        }
      }
    }
  }

  dynamic "health_check_custom_config" {
    for_each = (
      each.value.health_check_custom_failure_threshold != null
      ? [each.value.health_check_custom_failure_threshold]
      : []
    )

    content {
      failure_threshold = each.value
    }
  }

  tags = each.value.tags
}

######################################################################
