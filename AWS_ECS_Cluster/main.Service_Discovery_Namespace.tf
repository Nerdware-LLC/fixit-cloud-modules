######################################################################
### ECS Service Discovery Namespace

/* NOTE: The "private_dns_namespace" type allows both private DNS lookups
AND HTTP CloudMap API calls. Service discovery SERVICES are created/implemented
in the "AWS_ECS_Service" module (see "main.Service_Discovery.tf").  */

resource "aws_service_discovery_private_dns_namespace" "ECS_Service_Discovery_Namespace" {
  name        = var.service_discovery_namespace.name
  description = var.service_discovery_namespace.description
  vpc         = var.service_discovery_namespace.vpc_id
  tags        = var.service_discovery_namespace.tags
}

######################################################################
