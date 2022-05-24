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
  description = "Map of subnet resource objects."
  value       = aws_subnet.map
}

#---------------------------------------------------------------------
### VPC Peering Connections

output "VPC_Peering_Connection_Requests" {
  description = "Map of VPC Peering Connection resource objects."
  value = (
    length(keys(aws_vpc_peering_connection.map)) > 0
    ? aws_vpc_peering_connection.map
    : null
  )
}

output "VPC_Peering_Connections_Accepts" {
  description = "Map of VPC Peering Connection Accepter resource objects."
  value = (
    length(keys(aws_vpc_peering_connection_accepter.map)) > 0
    ? aws_vpc_peering_connection_accepter.map
    : null
  )
}

output "VPC_Peering_Connections_Options" {
  description = "Map of VPC Peering Connection Options resource objects."
  value = (
    length(keys(aws_vpc_peering_connection_options.map)) > 0
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
  value = (
    length(keys(aws_nat_gateway.map)) > 0
    ? aws_nat_gateway.map
    : null
  )
}

output "NAT_Gateway_Elastic_IPs" {
  description = "Map of NAT gateway elastic IP address resource objects."
  value = (
    length(keys(aws_eip.nat_gw_elastic_ips)) > 0
    ? aws_eip.nat_gw_elastic_ips
    : null
  )
}

#---------------------------------------------------------------------
### Route Tables

output "Public_Subnet_RouteTables" {
  description = "Map of PUBLIC subnet route table resource objects."
  value = (
    length(keys(aws_route_table.Public_Subnet_RouteTables)) > 0
    ? aws_route_table.Public_Subnet_RouteTables
    : null
  )
}

output "Private_Subnet_RouteTables" {
  description = "Map of PRIVATE subnet route table resource objects."
  value = (
    length(keys(aws_route_table.Private_Subnet_RouteTables)) > 0
    ? aws_route_table.Private_Subnet_RouteTables
    : null
  )
}

output "IntraOnly_Subnet_RouteTables" {
  description = "Map of INTRA-ONLY subnet route table resource objects."
  value       = one(aws_route_table.IntraOnly_Subnets_RouteTable)
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
