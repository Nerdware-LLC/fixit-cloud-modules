######################################################################
### Default VPC Components

locals {
  default_resource_tags = {
    for var_key, default_name in {
      "default_route_table"    = "Default_RouteTable"
      "default_network_acl"    = "Default_NACL"
      "default_security_group" = "Default_SecGroup"
      } : var_key => lookup(var.default_resource_tags, var_key, {
        Name = default_name
    })
  }
}

#---------------------------------------------------------------------
### Default Route Table:

resource "aws_default_route_table" "this" {
  default_route_table_id = aws_vpc.this.default_route_table_id
  route                  = [] # empty = no routing
  tags                   = local.default_resource_tags.default_route_table
}
# Note: this resource can NOT be used with 'aws_main_route_table_association'

#---------------------------------------------------------------------
### Default Network ACL:

resource "aws_default_network_acl" "this" {
  default_network_acl_id = aws_vpc.this.default_network_acl_id
  tags                   = local.default_resource_tags.default_network_acl
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
  vpc_id = aws_vpc.this.id
  tags   = local.default_resource_tags.default_security_group
  /* NO ingress/egress rules => DENY all traffic for any instance that's not
  explicitly associated with a custom, non-default aws_security_group resource */
}

######################################################################
