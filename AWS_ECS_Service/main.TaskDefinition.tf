######################################################################
### ECS Task Definitions

locals {
  container_definitions = jsondecode(var.task_definition.container_definitions)

  # Envoy must be provided; this is enforced by lifecycle precondition (below).
  envoy_container_def = one([
    for container_def in local.container_definitions : container_def
    if can(regex("(?i:envoy)", container_def.name))
  ])
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.task_definition.name
  requires_compatibilities = "EC2"

  cpu = coalesce(
    var.task_definition.cpu,
    data.aws_ec2_instance_type.task_host.default_vcpus * 1024 # cpu_units = number-of-vCPUs x 1024
  )
  memory = coalesce(
    var.task_definition.memory,
    data.aws_ec2_instance_type.task_host.memory_size
  )

  network_mode = var.network_params.assign_public_ip == false ? "awsvpc" : "bridge" # can't use awsvpc in public subnets

  execution_role_arn = var.task_definition.task_execution_role_arn # Role used by ECS container agent and Docker daemon to start containers.
  task_role_arn      = var.task_definition.task_role_arn           # Role used by all task containers to call AWS services.

  # PROPERTIES FOR INDIVIDUAL SERVICES/CONTAINERS:
  container_definitions = var.task_definition.container_definitions
  # TODO Add lifecycle precondition which ensures service images in PROD only ever use Docker DIGESTS, not names/tags.

  proxy_configuration {
    type           = "APPMESH"
    container_name = local.envoy_container_def.name
    properties = { # Replace below hard-coded proxy configs, get from local.envoy_container_def
      AppPorts         = "8080"
      EgressIgnoredIPs = "169.254.170.2,169.254.169.254"
      # IgnoredUID must match the "user" value in the Envoy container def
      IgnoredUID       = local.envoy_container_def.user
      ProxyIngressPort = 15000
      ProxyEgressPort  = 15001
    }
  }

  tags = var.task_definition.tags

  lifecycle {
    # Ensure an Envoy container def was provided.
    precondition {
      condition     = local.envoy_container_def != null
      error_message = <<-EOF
      No container definition found with name "Envoy" (case-insensitive); an Envoy
      container definition is required in "var.task_definition.container_definitions".
      EOF
    }
  }
}

######################################################################
