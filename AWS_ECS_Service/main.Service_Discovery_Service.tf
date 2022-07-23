######################################################################
### ECS Service Discovery Service

/* NOTE: The "private_dns_namespace" type used in the "AWS_ECS_Cluster"
module allows both private DNS lookups AND HTTP CloudMap API calls. */

resource "aws_service_discovery_service" "this" {
  name = var.service_discovery_service.name

  # dns_config, dns_records, health_check_custom_config
  dynamic "dns_config" {
    for_each = (
      var.service_discovery_service.dns_config != null
      ? [var.service_discovery_service.dns_config]
      : []
    )

    content {
      namespace_id = dns_config.value.namespace_id

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

  tags = var.service_discovery_service.tags
}

######################################################################
