######################################################################
### Default VPC Components

locals {
  DEFAULT_RESOURCE_NAMES = {
    default_vpc            = "Default_VPC"
    default_route_table    = "Default_VPC_Route_Table"
    default_network_acl    = "Default_VPC_Network_ACL"
    default_security_group = "Default_VPC_Security_Group"
  }

  default_resource_tags = {
    for resource, tags in var.default_vpc_component_tags : resource => (
      tags != null
      ? tags
      : { Name = local.DEFAULT_RESOURCE_NAMES[resource] }
    )
  }
}

# NOTE: TFSec rule ignored, since the goal of the below resource is to prevent usage.
#tfsec:ignore:aws-vpc-no-default-vpc
resource "aws_default_vpc" "this" {
  tags = local.default_resource_tags["default_vpc"]
}

#---------------------------------------------------------------------
### Default Route Table:

resource "aws_default_route_table" "this" {
  default_route_table_id = aws_default_vpc.this.default_route_table_id
  route                  = [] # empty = no routing
  tags                   = local.default_resource_tags["default_route_table"]
}

#---------------------------------------------------------------------
### Default Network ACL:

resource "aws_default_network_acl" "this" {
  default_network_acl_id = aws_default_vpc.this.default_network_acl_id
  tags                   = local.default_resource_tags["default_network_acl"]
  /* NO ingress/egress rules => DENY all traffic for any subnet that's not
  explicitly associated with a custom, non-default aws_network_acl resource */

  lifecycle {
    ignore_changes = [subnet_ids]
    # ignroe_changes explanation:
    # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_network_acl#managing-subnets-in-a-default-network-acl
  }
}

#---------------------------------------------------------------------
### Default Security Group:

resource "aws_default_security_group" "this" {
  vpc_id = aws_default_vpc.this.id
  tags   = local.default_resource_tags["default_security_group"]
  /* NO ingress/egress rules => DENY all traffic for any instance that's not
  explicitly associated with a custom, non-default aws_security_group resource */
}

######################################################################
