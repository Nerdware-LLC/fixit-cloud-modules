######################################################################
### AWS ELB

resource "aws_lb" "map" {
  for_each = var.load_balancers

  name               = each.key
  load_balancer_type = each.value.type

  # NETWORK
  ip_address_type = each.value.is_dualstack == true ? "dualstack" : "ipv4"
  internal        = coalesce(each.value.is_internal, false)
  subnets         = try(values(each.value.subnets)[*].subnet_id, null)
  security_groups = each.value.alb_security_group_ids

  dynamic "subnet_mapping" {
    for_each = each.value.subnets != null ? [each.value.subnets] : []

    content {
      subnet_id            = subnet_mapping.value.subnet_id
      allocation_id        = subnet_mapping.value.elastic_ip_allocation_id
      private_ipv4_address = subnet_mapping.value.private_ipv4_address
      ipv6_address         = subnet_mapping.value.ipv6_address
    }
  }

  # MISC CONFIGS
  enable_http2                     = coalesce(each.value.alb_should_enable_http2, true)
  enable_cross_zone_load_balancing = coalesce(each.value.nlb_enable_cross_zone_load_balancing, false)
  enable_deletion_protection       = coalesce(each.value.enable_deletion_protection, true)
  desync_mitigation_mode           = each.value.desync_mitigation_mode
  idle_timeout                     = coalesce(each.value.idle_timeout_seconds, 60)

  dynamic "access_logs" {
    for_each = each.value.access_logging != null ? [each.value.access_logging] : []

    content {
      bucket  = access_logs.value.s3_bucket_name
      prefix  = access_logs.value.log_prefix
      enabled = coalesce(access_logs.value.is_enabled, true)
    }
  }

  tags = each.value.tags
}

#---------------------------------------------------------------------
### Listeners

# resource "aws_lb_listener" "map" {
#
# }

######################################################################
