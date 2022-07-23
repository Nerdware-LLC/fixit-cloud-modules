######################################################################
### ECS Services

resource "aws_ecs_service" "this" {
  name            = var.ecs_service.name
  cluster         = var.ecs_service.ecs_cluster_arn
  task_definition = aws_ecs_task_definition.this.arn

  # INSTANCE SETTINGS
  launch_type         = "EC2"
  scheduling_strategy = "REPLICA"
  desired_count       = var.ecs_service.instance_count.desired

  # ECS Exec info => https://aws.amazon.com/blogs/containers/new-using-amazon-ecs-exec-access-your-containers-fargate-ec2/
  enable_execute_command = coalesce(var.ecs_service.enable_ecs_exec, false)

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.this.arn
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
    /* The "subnets" key/value is arbitrary, we just need this block to be
    conditional. "network_configuration" is only valid for the "awsvpc"
    networking mode, which can only be used in private subnets.  */
    for_each = (
      var.network_params.assign_public_ip != true
      ? { subnets = var.network_params.subnet_ids }
      : {}
    )
    content {
      subnets          = network_configuration.value.subnets
      security_groups  = var.network_params.security_group_ids
      assign_public_ip = var.network_params.assign_public_ip
    }
  }

  # SERVICE DISCOVERY
  service_registries {
    registry_arn = aws_service_discovery_service.this.arn
  }

  # ROLLING UDPATE CONTROLS
  force_new_deployment               = coalesce(var.rolling_update_controls.force_new_deployment, false)
  deployment_minimum_healthy_percent = coalesce(var.rolling_update_controls.deployment_minimum_healthy_percent, 100) # Never fall below desired_count.
  deployment_maximum_percent         = coalesce(var.rolling_update_controls.deployment_maximum_percent, 200)         # Run existing AND new, then xfer traffic to new.

  deployment_circuit_breaker {
    # If a deployment doesn't get at least 1 healthy instance, it rolls back to previous config.
    enable   = true
    rollback = true
  }

  # TAGS
  enable_ecs_managed_tags = true              # Tag EC2's with the cluster & service names.
  propagate_tags          = "TASK_DEFINITION" # Tag EC2's with the task def name.
  tags                    = var.ecs_service.tags

  # Allow external changes without TF plan difference (docs recommended).
  lifecycle {
    ignore_changes = [desired_count]
  }
}

######################################################################
