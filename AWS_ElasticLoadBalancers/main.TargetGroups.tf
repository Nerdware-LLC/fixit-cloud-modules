######################################################################
### AWS ELB Target Group

resource "aws_lb_target_group" "map" {
  for_each = var.target_groups

  name                               = each.key
  target_type                        = each.value.target_type
  port                               = each.value.port
  protocol                           = each.value.protocol
  protocol_version                   = each.value.protocol_version
  ip_address_type                    = each.value.ip_address_type
  vpc_id                             = each.value.vpc_id
  slow_start                         = each.value.slow_start_warmup_seconds
  load_balancing_algorithm_type      = each.value.load_balancing_algorithm_type
  lambda_multi_value_headers_enabled = each.value.lambda_multi_value_headers_enabled

  dynamic "health_check" {
    for_each = each.value.health_check != null ? [each.value.health_check] : []

    content {
      enabled             = health_check.value.is_enabled
      healthy_threshold   = health_check.value.healthy_threshold
      unhealthy_threshold = health_check.value.unhealthy_threshold
      interval            = health_check.value.interval
      matcher             = health_check.value.matcher
      path                = health_check.value.path
      port                = health_check.value.port
      protocol            = health_check.value.protocol
      timeout             = health_check.value.timeout
    }
  }

  tags = each.value.tags
}

resource "aws_lb_target_group_attachment" "map" {
  for_each = toset(flatten([
    for target_grp_name, target_grp_config in var.target_groups : [
      for target in try(coalesce(target_grp_config.targets, []), []) : jsonencode({
        target_group_arn  = aws_lb_target_group.map[target_grp_name].arn
        target_id         = target.id
        port              = target.port
        availability_zone = target.availability_zone
      })
    ]
  ]))

  target_group_arn  = jsondecode(each.value).target_group_arn
  target_id         = jsondecode(each.value).target_id
  port              = jsondecode(each.value).port
  availability_zone = jsondecode(each.value).availability_zone
}

######################################################################
