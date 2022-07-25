######################################################################
### ECS Task Definitions

locals {
  # Decode each Task Def's "container_definitions_json" for easier handling.
  task_definitions = {
    for task_def_name, task_def_config in var.task_definitions : task_def_name => merge(
      task_def_config,
      {
        container_definitions = jsondecode(task_def_config.container_definitions_json)
      }
    )
  }

  # Identify the Envoy container definition for proxy_configuration blocks.
  task_definitions_with_identified_envoy_configs = {
    for task_def_name, task_def_config in local.task_definitions : task_def_name => merge(
      task_def_config,
      {
        envoy_container_def = one([
          for container_def in task_def_config.container_definitions : container_def
          if can(regex("(?i:envoy)", container_def.name))
        ])
      }
    )
  }
}

resource "aws_ecs_task_definition" "map" {
  for_each = local.task_definitions_with_identified_envoy_configs

  family                   = each.key
  requires_compatibilities = ["EC2"]

  # CPU and MEMORY: try data.aws_ec2_instance_type lookup, else default to null.
  cpu = try(coalesce(
    each.value.cpu,
    data.aws_ec2_instance_type.map[each.key].default_vcpus * 1024 # cpu_units = number-of-vCPUs x 1024
  ), null)
  memory = try(coalesce(
    each.value.memory,
    data.aws_ec2_instance_type.map[each.key].memory_size
  ), null)

  # NETWORK
  network_mode = (
    var.ecs_services[each.value.ecs_service].network_configs.assign_public_ip == false
    ? "awsvpc" # can't use awsvpc in public subnets
    : "bridge"
  )

  execution_role_arn = each.value.task_execution_role_arn # Role used by ECS container agent and Docker daemon to start containers.
  task_role_arn      = each.value.task_role_arn           # Role used by all task containers to call AWS services.

  # CONTAINERS
  container_definitions = jsonencode([
    # Add APPMESH_RESOURCE_ARN env var to Envoy container definition
    for container_def_obj in each.value.container_definitions : merge(
      container_def_obj,
      {
        environment = flatten([
          lookup(container_def_obj, "environment", []),
          (
            container_def_obj.name == each.value.envoy_container_def.name
            ? [{
              name  = "APPMESH_RESOURCE_ARN"
              value = aws_appmesh_virtual_node.map[each.value.envoy_proxy_config.appmesh_node_name].arn
            }]
            : []
          )
        ])
      }
    )
  ])

  proxy_configuration {
    type           = "APPMESH"
    container_name = each.value.envoy_container_def.name
    properties = {
      AppPorts         = each.value.envoy_proxy_config.app_ports
      EgressIgnoredIPs = each.value.envoy_proxy_config.egress_ignored_ips
      # IgnoredUID must match the "user" value in the Envoy container def
      IgnoredUID       = each.value.envoy_container_def.user
      ProxyIngressPort = each.value.envoy_proxy_config.proxy_ingress_port
      ProxyEgressPort  = each.value.envoy_proxy_config.proxy_egress_port
    }
  }

  tags = each.value.tags

  lifecycle {
    # Ensure an Envoy container definition was provided.
    precondition {
      condition = alltrue([
        for task_def_name, task_def_config in local.task_definitions_with_identified_envoy_configs
        : task_def_config.envoy_container_def != null
      ])
      error_message = "All Task Defs must provide an Envoy container definition with name \"Envoy\" (case-insensitive)."
    }

    # TODO Add lifecycle precondition which ensures service images in PROD only ever use Docker DIGESTS, not names/tags.
  }
}

#---------------------------------------------------------------------

data "aws_ec2_instance_type" "map" {
  for_each = {
    for name, config in var.task_definitions : name => config
    if config.instance_type != null
  }

  instance_type = each.value.instance_type
}

######################################################################
