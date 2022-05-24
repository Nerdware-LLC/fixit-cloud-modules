######################################################################
### INPUT VARIABLES
######################################################################
### VPC

variable "vpc" {
  description = <<-EOF
  Config object for the VPC. All optional bools default to "true".

  VPC peering connections can be configured using the "request_peering_vpc_ids" and
  "accept_peering_connection_ids" properties, both of which map resource IDs to peering
  config objects. For peering connections in which your VPC is the requester, use the
  "request_..." property, which takes peer VPC IDs as keys; when your VPC is the accepter,
  use the "accept_..." property, which takes peering connection IDs as keys.

  If a peer VPC is within both the same account AND region, then neither the peer VPC
  region nor account ID need be provided. When the account and region are the same, the
  peering connection will be configured to auto-accept, so it won't be necessary for the
  peer VPC to manually configure acceptance of the peering connection unless they want to
  disable remote VPC DNS resolution (where public IPs map to private DNS hostnames). If
  either the VPC region or account ID are not the same, however, the peer VPC must
  manually accept the peering request. Peer accepter VPCs set the keys of the "accept_..."
  property to the IDs of the peering connections themselves. Both the requester and
  accepter will by default have remote VPC DNS resolution enabled, but
  "allow_remote_vpc_dns_resolution" can be set to false to disable the feature.

  Once a VPC peering connection has been established, the following subnet-level resource
  configs will need to be in place before peering connection traffic can proceed:
    - To permit EGRESS traffic, a subnet within the VPC from which the request originates
      must have a route table with at least one route configured with the peering
      connection ID using the receiving VPC's CIDR (or a subset thereof).
    - To permit INGRESS traffic, a subnet within the VPC which is the target of a request
      must have a network ACL with at least one rule allowing the request using the
      sending VPC's CIDR (or a subset thereof). The NACL rule must also specify the
      correct protocol and port-range, which will depend on the nature of the request.
  EOF

  type = object({
    cidr_block = string
    request_peering_vpc_ids = optional(map(object({
      peer_vpc_owner_account_id       = optional(string)
      peer_vpc_region                 = optional(string)
      allow_remote_vpc_dns_resolution = optional(bool)
      tags                            = optional(map(string))
    })))
    accept_peering_connection_ids = optional(map(object({
      allow_remote_vpc_dns_resolution = optional(bool)
      tags                            = optional(map(string))
    })))
    enable_dns_support   = optional(bool)
    enable_dns_hostnames = optional(bool)
    tags                 = optional(map(string))
  })
}

#---------------------------------------------------------------------
### Subnets

variable "subnets" {
  description = <<-EOF
  Map of subnet CIDRs to subnet config objects. All CIDR blocks must fit within the given
  VPC, and must not overlap with one another. The "type" property can be "PUBLIC",
  "PRIVATE", or "INTRA-ONLY"; these values correspond to subnet egress destinations:
  internet gateways for PUBLIC subnets, and NAT gateways for PRIVATE subnets. INTRA-ONLY
  subnets have both ingress and egress traffic disabled, which can be desirable for
  sensitive workloads that don't require internet access. The properties
  "map_public_ip_on_launch" and "contains_nat_gateway" both default to "false" and have no
  effect on non-PUBLIC subnets. For each availability zone used in your subnet configs, if
  there's at least one PRIVATE subnet, there must also be at least one PUBLIC subnet
  configured to contain a NAT gateway.

  > This module does not support the creation of private subnets for which egress traffic
    is routed to a NAT gateway in a different availability zone, for two reasons:
      1. Cross-AZ NAT incurs a slight latency hit
      2. Such a design undermines high-availability

  This module automatically generates network ACLs and route tables with common rules and
  routes which reflect the subnet types you provide. These resources are referred to as
  "Subnet-Type" resources, and they can be flexibly customized and/or entirely replaced by
  your own custom resources via the "custom_network_acl" and "custom_route_table" subnet
  properties. Brief descriptions of default Subnet-Type resource behavior is below; for
  more info, see "var.route_tables" and "var.network_acls".

  Subnet-Type Route Tables
  By default, each subnet will be associated with a route table which reflects its type:
    - PUBLIC Subnet-Type route table:
      - A single route table named "Public_Subnets_RouteTable" which routes egress traffic
        to the VPC's internet gateway.
      - By default all PUBLIC subnets are associated with it.
      - To override the default Subnet-Type route table for PUBLIC subnets, set "custom_route_table"
        to any custom route table named in var.route_tables.
    - PRIVATE Subnet-Type route tables:
      - One route table is created per NAT gateway; like the NAT gateways themselves, this
        module identifies NAT-connected route tables by the CIDR of the public subnet
        which contains the NAT gateway.
      - By default PRIVATE subnets are evenly distributed among route tables within the
        same AZ to spread out the load.
      - To explicitly set a specific route table for PRIVATE subnets, set
        "custom_route_table" to the CIDR of any PUBLIC subnet within the same AZ which
        contains a NAT gateway. Unless the desired route table will also contain custom
        non-default routes (e.g., a VPC peering connection) or tags, it need not be
        provided in var.route_tables since it will already exist.
    - INTRA-ONLY Subnet-Type route table:
      - A single route table named "IntraOnly_Subnets_RouteTable" which does not contain
        any routes, thereby disabling egress traffic.
      - All INTRA-ONLY subnets are associated with it.
      - The default Subnet-Type route table for INTRA-ONLY subnets cannot be overridden (use a
        different subnet type instead). Only tags can be added, using the RT's name.

  Subnet-Type Network ACLs
  By default, each subnet is associated with a network ACL with common rules reflective of its
  type. Detailed tables including the exact CIDR blocks and port ranges for the rules
  described below can be found in the README section "Subnet-Type Network ACLs".
    - PUBLIC Subnet-Type NACL ("Public_Subnets_NACL"):
      - Ingress: HTTP, HTTPS, and ephemeral ports.
      - Egress: HTTP, HTTPS, and ephemeral ports.
      - To override the NACL for PUBLIC subnets, set "custom_network_acl" to any custom
        NACL named in var.network_acls.
    - PRIVATE Subnet-Type NACL ("Private_Subnets_NACL"):
      - Ingress: Ephemeral ports.
      - Egress: HTTP, HTTPS, and ephemeral ports.
      - To override the NACL for PRIVATE subnets, set "custom_network_acl" to any custom
        NACL named in var.network_acls.
    - INTRA-ONLY Subnet-Type NACL ("IntraOnly_Subnets_NACL"):
      - Ingress: None, ingress not permitted.
      - Egress: None, egress not permitted.
      - The default Subnet-Type NACL for INTRA-ONLY subnets cannot be overridden (use a
        different subnet type instead). Only tags can be added, using the NACL's name.
  EOF

  type = map(object({
    # map keys: subnet CIDRs
    availability_zone       = string
    type                    = string           # enum: PUBLIC, PRIVATE, or INTRA-ONLY
    map_public_ip_on_launch = optional(bool)   # for public subnets
    contains_nat_gateway    = optional(bool)   # for public subnets
    custom_route_table      = optional(string) # for PUBLIC/PRIVATE subnets
    custom_network_acl      = optional(string) # for PUBLIC/PRIVATE subnets
    tags                    = optional(map(string))
  }))

  # Ensure all subnet "type" values are one of the allowed enum values.
  validation {
    condition = alltrue([
      for type in values(var.subnets)[*].type : contains(["PUBLIC", "PRIVATE", "INTRA-ONLY"], type)
    ])
    error_message = "All subnet \"type\" values must be either \"PUBLIC\", \"PRIVATE\", or \"INTRA-ONLY\"."
  }

  # Ensure for each AZ used by PRIVATE subnets, there's min 1 PUBLIC subnet in same AZ with "contains_nat_gateway"=true
  validation {
    condition = alltrue([
      for private_subnet_AZ in distinct([
        for cidr, subnet in var.subnets : subnet.availability_zone if subnet.type == "PRIVATE"
      ])
      : 1 <= length([
        for cidr, subnet in var.subnets : subnet
        if alltrue([
          subnet.type == "PUBLIC",
          subnet.availability_zone == private_subnet_AZ,
          lookup(subnet, "contains_nat_gateway", false) == true
        ])
      ])
    ])
    error_message = "For each AZ used by private subnets, there must be at least 1 public subnet in the same AZ with \"contains_nat_gateway\" set to \"true\"."
  }

  # Ensure any "custom_route_table" values point to a public subnet in same AZ with "contains_nat_gateway"=true.
  validation {
    condition = alltrue([
      for cidr, subnet in var.subnets : anytrue([
        subnet.type != "PRIVATE",        # condition only applies to private subnets
        !can(subnet.custom_route_table), # condition passes if this isn't set
        (                                # else check target validity
          try(var.subnets[subnet.custom_route_table].contains_nat_gateway, false) == true &&
          try(var.subnets[subnet.custom_route_table].availability_zone, null) == subnet.availability_zone
          # The AZ check is wrapped in try() to prevent lookup error on subnet.custom_route_table when it's not provided.
        )
      ])
    ])
    error_message = "Any private subnet \"custom_route_table\" values must be the CIDR of a public subnet in the same AZ with \"contains_nat_gateway\" set to \"true\"."
  }
}

#---------------------------------------------------------------------
### Custom Route Table

variable "route_tables" {
  description = <<-EOF
  Map of route table names to route table config objects. Route tables do not have names
  in AWS, but the name values you provide will be used by this module to properly identify
  route tables for the purposes of route customization and subnet association. For PRIVATE
  subnet route tables, the name of the route table must be the CIDR of a PUBLIC subnet
  within the same AZ which contains a NAT gateway.

  The route table config objects can contain custom "route_cidrs" and/or "tags".
  "route_cidrs" maps CIDRs of route destinations to objects configuring each respective
  route. Any valid CIDR block can used except for the "0.0.0.0/0" egress CIDR, which is
  automatically configured for each subnet based on its "type" and cannot be overridden.
  To assign a PRIVATE subnet to a particular route table, set its "custom_route_table"
  property in var.subnets to the CIDR of the PUBLIC subnet which contains the desired NAT
  gateway; unless that route table will also contain custom routes (e.g., a VPC peering
  connection), it need not be provided in this variable.

  Subnet-Type Route Tables
  By default, route tables will be created which reflect the "type" of subnets included in
  your "var.subnets" input, which this module refers to as "Subnet-Type" route tables. For
  PUBLIC subnets, one route table is created named "Public_Subnets_RouteTable" which
  routes egress traffic to the VPC's internet gateway. For INTRA-ONLY subnets, one route
  table is created named "IntraOnly_Subnets_RouteTable" which does not contain any routes,
  thereby disabling both ingress and egress traffic for associated subnets. For PRIVATE
  subnets, one route table is created for each NAT gateway included in your "var.subnets"
  config; like the NAT gateways themselves, this module identifies NAT-connected route
  tables by the CIDR of the PUBLIC subnet which contains the NAT gateway. To add routes
  and/or tags to any of the Subnet-Type route tables, simply use their identifier (route
  table name, or for private subnets the CIDR of the subnet which contains the NAT) as a
  key in this variable, with the value set to an object with your desired configs.

  Custom Route Tables
  To create your own route table, simply use your own custom route table name as a key in
  this variable, and then associate subnets with the route table via the
  "custom_route_table" property in your var.subnets input. If all subnets of any given
  type are assigned to custom route tables, then the module-provided route table for that
  Subnet-Type will not be created.
  EOF

  type = map(object({
    # map keys: route table identifiers (names, or for private subnets CIDRs of NAT-containing public subnets)
    routes = optional(map(object({
      # map keys: CIDRs of route destinations
      vpc_peering_connection_id = optional(string) # for private/public subnets
    })))
    tags = optional(map(string))
    })
  )

  default = {}

  # Ensure all RT "routes" objects only include 1 route-type key
  validation {
    condition = alltrue([
      for custom_rt in values(var.route_tables) : alltrue([
        for route_cidr, route_config in coalesce(custom_rt.routes, {}) : 1 == length(keys(route_config))
      ])
    ])
    error_message = "Invalid combination of properties on one or more custom route table \"routes\". Each route must only contain \"cidr\" and one other key."
  }
}

#---------------------------------------------------------------------
### Network ACLs

variable "network_acls" {
  description = <<-EOF
  Map of network ACL names to config objects. NACLs do not have names in AWS, but the name
  values you provide will be used by this module to properly identify NACLs for the
  purposes of rule customization and subnet assignment.

  Subnet-Type Network ACLs
  By default, a network ACL will be created for each subnet type included in your
  "var.subnets" input, which this module refers to as "Subnet-Type" NACLs. These NACLs are
  named "Public_Subnets_NACL", "Private_Subnets_NACL", and "IntraOnly_Subnets_NACL". A
  list of default rules provided to each Subnet-Type NACL is available in the README
  ("Subnet-Type Network ACLs"). To add or modify rules or tags for any of the Subnet-Type
  NACLs, simply use the NACL's name as a key, and any rules/tags you include will be
  merged in. User input is given merge precedence, so using any module-provided rule
  numbers like "100" will result in the rule being overwritten.

  Custom Network ACLs
  To create your own NACL, simply use your own custom NACL name as a key in this variable,
  and then associate subnets with the NACL via the "custom_network_acl" property in your
  var.subnets configs. If all subnets of any given type are assigned to custom NACLs, then
  the Subnet-Type NACL for that type will not be created.

  Rule Configs
  Both the "ingress" and "egress" properties map quoted rule numbers (e.g., "100") to rule
  config objects. If not provided, "protocol" defaults to "tcp". If "from_port" and
  "to_port" are the same, you can simply provide just "port", which will map to both. If
  you need the CIDR of a particular AWS service, like EC2 Instance Connect, you can pass
  values like "ec2_instance_connect" to the "cidr_block" property. A list of supported AWS
  service values is available in the section "CIDR Blocks: AWS Services" in the README.
  EOF

  type = map(object({
    access = optional(object({
      ingress = optional(map(object({
        # map keys: quoted rule numbers (e.g., "100")
        cidr_block = string
        protocol   = optional(string)
        port       = optional(number)
        from_port  = optional(number)
        to_port    = optional(number)
      })))
      egress = optional(map(object({
        # map keys: quoted rule numbers (e.g., "100")
        cidr_block = string
        protocol   = optional(string)
        port       = optional(number)
        from_port  = optional(number)
        to_port    = optional(number)
      })))
    }))
    tags = optional(map(string))
  }))

  default = {}

  # Ensure any ingress/egress rules all contain valid arguments.
  validation {
    condition = alltrue([
      for nacl_name, nacl in var.network_acls : alltrue([
        for access_type, rules_map in lookup(nacl, "access", {}) : alltrue([
          for rule_num, rule in rules_map : alltrue([
            # Ensure cidr_block is a valid CIDR or a supported AWS Service Enum
            (
              can(cidrsubnet(rule.cidr_block, 0, 0)) ||
              contains(["ec2_instance_connect", "globalaccelerator"], rule.cidr_block)
            ),
            # Ensure all rules contain port-defining properties
            (
              can(rule.default_port) ||
              can(rule.port) ||
              (can(rule.from_port) && can(rule.to_port))
            )
          ])
        ])
      ])
    ])
    error_message = "Invalid port-defining properties on one or more network ACL rule config objects."
  }
}

#---------------------------------------------------------------------
### Security Groups

variable "security_groups" {
  description = <<-EOF
  Map of Security Group names to config objects. Within the "access" config object, each
  ingress/egress rule config must specify a "description", a port/port-range, and an
  access target. For the port range, if the "from_port" and "to_port" arguments would be
  the same, you can provide just "port" which will map to both. A rule's access target
  must be specified using one of the following properties:
    - "peer_security_group_id"    ID of an existing Security Group
    - "peer_security_group"       Name of another SG in your var.security_groups input
    - "aws_service"               Enum value representing a supported AWS service (see below)
    - "cidr_blocks"               List of CIDR blocks
    - "self"                      The SG itself

  AWS Services
  If you need the CIDR of a particular AWS service, like EC2 Instance Connect, you can
  pass values like "ec2_instance_connect" to the "aws_service" property. A list of
  supported AWS service values is available in the section "CIDR Blocks: AWS Services" in
  the README.
  EOF

  type = map(object({
    # map keys: security group names
    description = string
    access = object({
      ingress = optional(list(object({
        description            = string
        protocol               = optional(string)
        port                   = optional(number)
        from_port              = optional(number)
        to_port                = optional(number)
        peer_security_group_id = optional(string)
        peer_security_group    = optional(string)
        aws_service            = optional(string)
        cidr_blocks            = optional(list(string))
        self                   = optional(bool)
      })))
      egress = optional(list(object({
        description            = string
        protocol               = optional(string)
        port                   = optional(number)
        from_port              = optional(number)
        to_port                = optional(number)
        peer_security_group_id = optional(string)
        peer_security_group    = optional(string)
        aws_service            = optional(string)
        cidr_blocks            = optional(list(string))
        self                   = optional(bool)
      })))
    })
    tags = optional(map(string))
  }))

  default = {}

  # Ensure all SecGrp rule configs contain valid arguments.
  validation {
    condition = alltrue([
      for sg_name, sg_config in var.security_groups : alltrue([
        for access_type, rule_list in sg_config.access : alltrue([
          for rule in rule_list : alltrue([
            # Ensure all rules contain "port" OR ("from_port" AND "to_port")
            can(rule.port) || (can(rule.from_port) && can(rule.to_port)),
            # Ensure all rules contain exactly one of the listed keys
            1 == length(setintersection(
              keys(rule),
              ["peer_security_group_id", "peer_security_group", "aws_service", "cidr_blocks", "self"]
            )),
            # If rule uses "peer_security_group", ensure the named SecGrp was provided
            (
              lookup(rule, "peer_security_group", null) == null ||
              can(var.security_groups[rule.peer_security_group])
            )
          ])
        ])
      ])
    ])
    error_message = "Invalid combination of properties on one or more security group rule config objects."
  }
}

#---------------------------------------------------------------------
### Misc Resource Tags

variable "internet_gateway_tags" {
  description = "Tags for the internet gateway."
  type        = map(string)
  default     = null
}

variable "nat_gateway_tags" {
  description = <<-EOF
  Map of NAT-containing public subnet CIDRs to tags for each respective
  subnet's NAT gateway.
  EOF

  type    = map(map(string))
  default = null
}

variable "nat_gateway_elastic_ip_tags" {
  description = <<-EOF
  Map of NAT-containing public subnet CIDRs to tags for each respective
  subnet's NAT-associated elastic IP address.
  EOF

  type    = map(map(string))
  default = null
}

variable "default_route_table_tags" {
  description = "Tags for the VPC's default route table."
  type        = map(string)
  default     = null
}

variable "default_network_acl_tags" {
  description = "Tags for the VPC's default network ACL."
  type        = map(string)
  default     = null
}

variable "default_security_group_tags" {
  description = "Tags for the VPC's default security group."
  type        = map(string)
  default     = null
}

######################################################################
