######################################################################
### ECS Capacity Providers

resource "aws_ecs_capacity_provider" "this" {
  name = var.capacity_provider.name

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.this.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      status = "ENABLED"
      # 'step_size' = the number of container instances that ECS will scale in/out at one time.
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 1
    }
  }

  tags = var.capacity_provider.tags
}

######################################################################
