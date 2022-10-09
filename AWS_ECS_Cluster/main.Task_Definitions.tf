######################################################################
### ECS Task Definitions

resource "aws_ecs_task_definition" "map" {
  for_each = var.task_definitions

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
  container_definitions = jsonencode(flatten([
    # Service container
    each.value.container_definitions.service_container_def,
    # Envoy container with APPMESH_RESOURCE_ARN env var added in
    merge(each.value.container_definitions.envoy_container_def, {
      environment = concat(
        # Include any "environment" values provided by user
        lookup(each.value.container_definitions.envoy_container_def, "environment", []),
        [{
          name  = "APPMESH_RESOURCE_ARN"
          value = aws_appmesh_virtual_node.map[each.value.envoy_proxy_config.appmesh_node_name].arn
        }]
      )
    }),
    # Add other container defs if "other_container_defs" was provided
    (
      each.value.container_definitions.other_container_defs != null
      ? each.value.container_definitions.other_container_defs
      : []
    )
  ]))

  proxy_configuration {
    type           = "APPMESH"
    container_name = each.value.container_definitions.envoy_container_def.name
    properties = {
      /* NOTES re: proxy_configuration.properties

      - AppPorts (Required) List of ports that the application uses. Network traffic to these ports is forwarded to the ProxyIngressPort and ProxyEgressPort.
      - EgressIgnoredIPs (Required) Comma-separated list. The outbound traffic going to these specified IP addresses is ignored and not redirected to the ProxyEgressPort. It can be an empty list.
          Commonly-included values:
          - 169.254.170.2     Task metadata service IP
          - 169.254.169.254   EC2 metadata service IP
      - IgnoredUID (Required) The UID of the proxy container as defined by the user parameter in a container definition. This is used to ensure the proxy ignores its own traffic. If IgnoredGID is specified, this field can be empty.
      - ProxyIngressPort (Required) Specifies the port to which incoming traffic to the AppPorts is directed.
      - ProxyEgressPort (Required) Specifies the port to which outgoing traffic from the AppPorts is directed.
      */
      AppPorts         = join(",", each.value.container_definitions.service_container_def.portMappings[*].containerPort)
      EgressIgnoredIPs = coalesce(each.value.proxy_config.egress_ignored_ips, "169.254.170.2,169.254.169.254")
      IgnoredUID       = each.value.container_definitions.envoy_container_def.user
      ProxyIngressPort = coalesce(each.value.proxy_config.proxy_ingress_port, 15000)
      ProxyEgressPort  = coalesce(each.value.proxy_config.proxy_ingress_port, 15001)
    }
  }

  tags = each.value.tags
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
