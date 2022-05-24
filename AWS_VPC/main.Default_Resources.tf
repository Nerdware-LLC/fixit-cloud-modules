######################################################################
### Default VPC Components
######################################################################
### Default Route Table:

resource "aws_default_route_table" "this" {
  default_route_table_id = aws_vpc.this.default_route_table_id
  route                  = [] # empty = no routing
  tags                   = var.default_route_table_tags
}
# Note: this resource can NOT be used with 'aws_main_route_table_association'

#---------------------------------------------------------------------
### Default Network ACL:

resource "aws_default_network_acl" "this" {
  default_network_acl_id = aws_vpc.this.default_network_acl_id
  tags                   = var.default_network_acl_tags
  /* No ingress/egress rules --> DENY all traffic for any subnet that's
  not explicitly associated with a user-provisioned network ACL.  */

  lifecycle {
    ignore_changes = [subnet_ids]
    # ignore_changes explanation:
    # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_network_acl#managing-subnets-in-a-default-network-acl
  }
}

#---------------------------------------------------------------------
### Default Security Group:

resource "aws_default_security_group" "this" {
  vpc_id = aws_vpc.this.id
  tags   = var.default_security_group_tags
  /* No ingress/egress rules --> DENY all traffic for any instance that's
  not explicitly associated with a user-provisioned security group.  */
}

######################################################################
