######################################################################
### OUTPUTS
######################################################################
### VPC

output "VPC" {
  description = "The VPC resource object."
  value       = aws_vpc.this
}

#---------------------------------------------------------------------
### Subnets

output "Subnets" {
  description = "Map of subnet resource objects merged with their respective input params."
  value = {
    for cidr, subnet in aws_subnet.map : cidr => merge(var.subnets[cidr], subnet)
  }
}

#---------------------------------------------------------------------
### VPC Peering Connections

output "VPC_Peering_Connection_Requests" {
  description = "Map of VPC Peering Connection resource objects."
  value = (
    aws_vpc_peering_connection.map != {}
    ? aws_vpc_peering_connection.map
    : null
  )
}

output "VPC_Peering_Connection_Accepts" {
  description = "Map of VPC Peering Connection Accepter resource objects."
  value = (
    aws_vpc_peering_connection_accepter.map != {}
    ? aws_vpc_peering_connection_accepter.map
    : null
  )
}

output "VPC_Peering_Connection_Options" {
  description = "Map of VPC Peering Connection Options resource objects."
  value = (
    aws_vpc_peering_connection_options.map != {}
    ? aws_vpc_peering_connection_options.map
    : null
  )
}

#---------------------------------------------------------------------
### Gateways

output "Internet_Gateway" {
  description = "The internet gateway resource object."
  value       = one(aws_internet_gateway.list)
}

output "NAT_Gateways" {
  description = "Map of NAT gateway resource objects."
  value       = aws_nat_gateway.map != {} ? aws_nat_gateway.map : null
}

output "NAT_Gateway_Elastic_IPs" {
  description = "Map of NAT gateway elastic IP address resource objects."
  value = (
    aws_eip.nat_gw_elastic_ips != {}
    ? aws_eip.nat_gw_elastic_ips
    : null
  )
}

#---------------------------------------------------------------------
### Route Tables

output "RouteTables" {
  description = "Map of route table resource objects."
  value       = aws_route_table.map != {} ? aws_route_table.map : null
}

#---------------------------------------------------------------------
### Network ACL Outputs

output "Network_ACLs" {
  description = "Map of network ACL resource objects."
  value       = aws_network_acl.map
}

#---------------------------------------------------------------------
### Security Group Outputs

output "Security_Groups" {
  description = "Map of security group resource objects."
  value       = aws_security_group.map
}

#---------------------------------------------------------------------
### VPC Endpoint Outputs

output "VPC_Endpoints" {
  description = "Map of VPC Endpoint resource objects."
  value       = aws_vpc_endpoint.map
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
