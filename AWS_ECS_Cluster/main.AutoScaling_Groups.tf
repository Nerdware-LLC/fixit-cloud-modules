######################################################################
### EC2 AutoScaling Group

resource "aws_autoscaling_group" "map" {
  for_each = var.autoscaling_groups

  name                = each.key
  vpc_zone_identifier = each.value.subnet_ids
  # The below params reflect ECS managed scaling
  min_size              = each.value.instance_count.min
  desired_capacity      = each.value.instance_count.desired
  max_size              = each.value.instance_count.max
  protect_from_scale_in = true

  launch_template {
    id      = aws_launch_template.map[each.value.task_host_launch_template_name].id
    version = coalesce(each.value.task_host_launch_template_version, "$Default")
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = coalesce(each.value.tags, [])

    content {
      key                 = tag.value.key
      value               = tag.value.value
      propagate_at_launch = tag.value.propagate_at_launch
    }
  }
}

######################################################################
