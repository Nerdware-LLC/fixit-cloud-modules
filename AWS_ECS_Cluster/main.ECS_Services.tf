######################################################################
### ECS Services

resource "aws_ecs_service" "map" {
  for_each = var.ecs_services

  name            = each.key
  cluster         = aws_ecs_cluster.this.arn
  task_definition = aws_ecs_task_definition.map[each.value.task_definition_name].arn

  # INSTANCE SETTINGS
  launch_type            = "EC2"
  scheduling_strategy    = "REPLICA"
  enable_execute_command = coalesce(each.value.enable_ecs_exec, false)
  desired_count = lookup(
    # Defined by the Service's CapacityProvider's AutoScalingGroup inputs.
    var.autoscaling_groups,
    var.capacity_providers[each.value.capacity_provider_name].autoscaling_group_name
  ).instance_count.desired

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.map[each.value.capacity_provider_name].arn
    base              = 1
    weight            = 1
  }

  # PLACEMENT (note: constraints eval'd before strategies)
  placement_constraints {
    type = "distinctInstance"
  }
  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }

  # NETWORK
  dynamic "network_configuration" {
    for_each = each.value.network_configs.assign_public_ip != true ? [each.value.network_configs] : []
    /* "network_configuration" is only valid for the "awsvpc"
    networking mode, which can only be used in private subnets. */
    content {
      subnets          = each.value.network_configs.subnet_ids
      security_groups  = each.value.network_configs.security_group_ids
      assign_public_ip = each.value.network_configs.assign_public_ip
    }
  }

  # SERVICE DISCOVERY
  service_registries {
    registry_arn = aws_service_discovery_service.map[each.value.service_discovery_service].arn
  }

  # ROLLING UDPATE CONTROLS
  force_new_deployment               = try(each.value.rolling_update_controls.force_new_deployment, false)
  deployment_minimum_healthy_percent = try(coalesce(each.value.rolling_update_controls.deployment_minimum_healthy_percent, 100), 100) # Never fall below desired_count.
  deployment_maximum_percent         = try(coalesce(each.value.rolling_update_controls.deployment_maximum_percent, 200), 200)         # Run existing AND new, then xfer traffic to new.

  deployment_circuit_breaker {
    # If a deployment doesn't get at least 1 healthy instance, it rolls back to previous config.
    enable   = true
    rollback = true
  }

  # TAGS
  enable_ecs_managed_tags = true              # Tag EC2's with the cluster & service names.
  propagate_tags          = "TASK_DEFINITION" # Tag EC2's with the task def name.
  tags                    = each.value.tags

  # Allow external changes without TF plan difference (docs recommended).
  lifecycle {
    ignore_changes = [desired_count]
  }
}

######################################################################
