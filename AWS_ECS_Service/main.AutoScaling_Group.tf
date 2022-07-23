######################################################################
### EC2 AutoScaling Group

resource "aws_autoscaling_group" "this" {
  name                = var.autoscaling_group.name
  vpc_zone_identifier = var.network_params.subnet_ids
  # The below params reflect ECS managed scaling
  min_size              = var.ecs_service.instance_count.min
  desired_capacity      = var.ecs_service.instance_count.desired
  max_size              = var.ecs_service.instance_count.max
  protect_from_scale_in = true

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Default"
  }

  tags = flatten([
    {
      key                 = "AmazonECSManaged"
      value               = ""
      propagate_at_launch = true
    },
    [
      for tag_key, tag_value in var.autoscaling_group.tags : {
        key                 = tag_key
        value               = tag_value
        propagate_at_launch = false
      }
    ]
  ])
}

######################################################################
