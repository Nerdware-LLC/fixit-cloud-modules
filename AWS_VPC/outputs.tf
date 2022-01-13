######################################################################
### OUTPUTS
#---------------------------------------------------------------------
### VPC + Subnets

output "VPC" {
  description = "The VPC resource object."
  value       = aws_vpc.this
}

output "Subnets" {
  description = <<-EOF
  Map of subnet resource objects, with CIDR blocks as keys. User-provided values
  "egress_destination" and "contains_nat_gateway" are merged into the resource objects.
  To facilitate easier filtering of subnet outputs, the boolean "is_public_subnet" is
  also added, with the value being "true" for subnets where "egress_destination" is
  set to "INTERNET_GATEWAY".
  EOF
  value = {
    for cidr, subnet in aws_subnet.map : cidr => merge(
      var.subnets[cidr],
      subnet,
      {
        is_public_subnet = var.subnets[cidr].egress_destination == "INTERNET_GATEWAY"
      }
    )
  }
}

#---------------------------------------------------------------------
### Gateways

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

#---------------------------------------------------------------------
### Route Tables

output "RouteTables" {
  description = "Map of route table resource objects, with \"egress_destination\" values as keys."
  value       = aws_route_table.map
}

#---------------------------------------------------------------------
### Network ACL Outputs

output "Network_ACLs" {
  description = "A list of network ACL resource objects with their respective RULES merged in."
  value = [
    for nacl in aws_network_acl.list : merge(nacl, {
      RULES = [
        for nacl_rule in aws_network_acl_rule.nacl_rules : nacl_rule
        if nacl_rule.network_acl_id == nacl.id
      ]
    })
  ]
}

#---------------------------------------------------------------------
### Security Group Outputs

output "Security_Groups" {
  description = "A map of security group resource objects with their respective RULES merged in."
  value = {
    for sec_grp_name, sec_grp in aws_security_group.map : sec_grp_name => merge(sec_grp, {
      RULES = [
        for sec_grp_rule in aws_security_group_rule.list : sec_grp_rule
        if sec_grp_rule.security_group_id == sec_grp.id
      ]
    })
  }
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
