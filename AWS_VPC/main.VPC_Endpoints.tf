######################################################################
### VPC Endpoints

locals {
  /* Normalize VPC endpoint inputs:
    - svc keys        Force lowercase
    - type            If null, default "Interface"
    - service_name    Pattern-based             */
  vpc_endpoints = {
    for svc, svc_endpoint_config in var.vpc_endpoints : lower(svc) => merge(
      svc_endpoint_config,
      {
        type = coalesce(svc_endpoint_config.type, "Interface")
        service_name = (
          # All services adhere to a common format except for sagemaker
          lower(svc) == "sagemaker"
          ? "aws.sagemaker.${data.aws_region.current.name}.notebook"
          : "com.amazonaws.${data.aws_region.current.name}.${lower(svc)}"
        )
      }
    )
  }
}

resource "aws_vpc_endpoint" "map" {
  for_each = local.vpc_endpoints

  # Endpoint Properties
  vpc_id            = aws_vpc.this.id
  service_name      = each.value.service_name
  vpc_endpoint_type = each.value.type
  auto_accept       = each.value.auto_accept # only applicable when the endpoint and svc are in the same account
  policy            = each.value.policy

  private_dns_enabled = ( # only for type "Interface"
    each.value.type == "Interface"
    ? coalesce(each.value.enable_private_dns, true)
    : null
  )

  subnet_ids = ( # only for types "Interface" and "GatewayLoadBalancer"
    each.value.type != "Gateway"
    ? [for cidr, subnet in local.subnet_resources : subnet.id if contains(each.value.subnet_cidrs, cidr)]
    : null
  )

  security_group_ids = ( # only for type "Interface"
    each.value.type == "Interface"
    ? [for sg_name, sg in aws_aws_security_group.map : sg.id if contains(each.value.security_groups, sg_name)]
    : null
  )

  route_table_ids = ( # only for type "Gateway"
    each.value.type == "Gateway"
    ? [for rt_name, rt in aws_route_table.map : rt.id if contains(each.value.route_tables, rt_name)]
    : null
  )

  timeouts {
    create = try(each.value.timeouts.create, "10m")
    update = try(each.value.timeouts.update, "10m")
    delete = try(each.value.timeouts.delete, "10m")
  }

  tags = each.value.tags
}

######################################################################
