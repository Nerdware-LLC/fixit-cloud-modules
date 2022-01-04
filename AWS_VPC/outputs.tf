######################################################################
### OUTPUTS - RESOURCE OBJECTS

output "VPC" {
  description = "The VPC resource object."
  value       = aws_vpc.this
}

output "Subnets" {
  description = <<-EOF
  Map of subnet resource objects, with CIDR blocks as keys. User-provided values
  "egress_destination" and "contains_nat_gateway" are merged into the resource objects.
  EOF
  value = {
    for cidr, subnet in aws_subnet.map : cidr => merge(var.subnets[cidr], subnet)
  }
}

output "Internet_GW" {
  description = "The internet gateway resource object."
  value       = one(aws_nat_gateway.this)
}

output "NAT_GW" {
  description = "The NAT gateway resource object."
  value       = one(aws_nat_gateway.this)
}

output "NAT_GW_EIP" {
  description = "The NAT gateway's elastic IP address resource object."
  value       = one(aws_eip.NAT_GW_EIP)
}

output "RouteTables" {
  description = "Map of route table resource objects, with \"egress_destination\" values as keys."
  value       = aws_route_table.map
}

#---------------------------------------------------------------------
### Default VPC-Resource Outputs

output "Default_RouteTable" {
  description = "The VPC's default route table resource object."
  value       = aws_default_route_table.this
}

output "Default_NetworkACL" {
  description = "The VPC's default network ACL resource object."
  value       = aws_default_network_acl.this
}

output "Default_SecurityGroup" {
  description = "The VPC's default security group resource object."
  value       = aws_default_security_group.this
}

######################################################################
