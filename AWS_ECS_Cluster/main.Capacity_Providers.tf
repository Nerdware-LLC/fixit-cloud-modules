######################################################################
### ECS Capacity Providers

resource "aws_ecs_capacity_provider" "map" {
  for_each = var.capacity_providers

  name = each.key

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.map[each.value.autoscaling_group_name].arn
    managed_termination_protection = (
      each.value.should_enable_managed_termination_protection != false
      ? "ENABLED" # <-- default
      : "DISABLED"
    )

    dynamic "managed_scaling" {
      for_each = (
        each.value.managed_scaling.is_enabled != false
        ? [each.value.managed_scaling]
        : []
      )

      content {
        status = "ENABLED"
        # 'step_size' = the number of container instances that ECS will scale in/out at one time.
        minimum_scaling_step_size = coalesce(managed_scaling.value.minimum_scaling_step_size, 1)
        maximum_scaling_step_size = coalesce(managed_scaling.value.maximum_scaling_step_size, 1)
      }
    }
  }

  tags = each.value.tags
}

######################################################################
