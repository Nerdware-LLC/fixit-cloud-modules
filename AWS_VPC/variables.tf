######################################################################
### INPUT VARIABLES
######################################################################
### VPC

variable "vpc" {
  description = <<-EOF
  Config object for the VPC. All optional bools default to "true".
  For more info:
    - [`VPC` README](#vpc)
    - [Usage example](examples/terragrunt.hcl)
  EOF

  type = object({
    cidr_block = string
    peering_request_vpc_ids = optional(map(
      # map keys: peer VPC IDs
      object({
        peer_vpc_owner_account_id       = optional(string)
        peer_vpc_region                 = optional(string)
        allow_remote_vpc_dns_resolution = optional(bool)
        tags                            = optional(map(string))
      })
    ))
    peering_accept_connection_ids = optional(map(
      # map keys: peering connection IDs
      object({
        allow_remote_vpc_dns_resolution = optional(bool)
        tags                            = optional(map(string))
      })
    ))
    enable_dns_support   = optional(bool)
    enable_dns_hostnames = optional(bool)
    tags                 = optional(map(string))
  })
}

#---------------------------------------------------------------------
### Subnets

variable "subnets" {
  description = <<-EOF
  Map of subnet CIDRs to subnet config objects. For each subnet, "type"
  must be either "PUBLIC", "PRIVATE", or "INTRA-ONLY". The properties
  "map_public_ip_on_launch" and "contains_nat_gateway" both default to
  false, and have no effect on non-public subnets. Public and private
  subnets can be configured to use specific route tables and/or NACLs
  via the "route_table" and "network_acl" properties respectively;
  these have no effect on intra-only subnets. For more info:
    - [`Subnets` README](#subnets)
    - [Usage example](examples/terragrunt.hcl)
  EOF

  type = map(
    # map keys: subnet CIDRs
    object({
      availability_zone       = string
      type                    = string
      map_public_ip_on_launch = optional(bool)
      contains_nat_gateway    = optional(bool)
      route_table             = optional(string)
      network_acl             = optional(string)
      tags                    = optional(map(string))
    })
  )

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
}

#---------------------------------------------------------------------
### Custom Route Table

variable "route_tables" {
  description = <<-EOF
  Map of route table names to route table config objects. Peering connection
  routes can be configured in one of two ways: if VPC is the peering REQUESTER,
  use "peering_request_vpc_id", otherwise if VPC is the peering ACCEPTER, use
  "peering_connection_id". Custom route tables for PRIVATE subnets can set their
  default route ("0.0.0.0/0") using "nat_gateway_subnet_cidr", which must be set
  to the CIDR of a NAT-containing PUBLIC subnet. For more info:
    - [`Route Tables` README](#route-tables)
    - [Usage example](examples/terragrunt.hcl)
  EOF

  type = map(
    # map keys: internal route table "names"
    object({
      routes = optional(map(
        # map keys: CIDRs of route destinations
        object({
          nat_gateway_subnet_cidr      = optional(string)
          peering_request_vpc_id       = optional(string)
          peering_accept_connection_id = optional(string)
        })
      ))
      tags = optional(map(string))
    })
  )

  default = {}

  # Ensure all RT "routes" objects only include 1 route-type key
  validation {
    condition = alltrue([
      for rt in values(var.route_tables) : alltrue([
        for route_cidr, route_config in coalesce(rt.routes, {}) : 1 == length(keys(route_config))
      ])
    ])
    error_message = "Invalid route configs on one or more route tables; route config objects must use exactly one route-type property."
  }
}

#---------------------------------------------------------------------
### Network ACLs

variable "network_acls" {
  description = <<-EOF
  Map of network ACL names to config objects. For more info:
    - [`Network ACLs` README](#network-acls)
    - [Usage example](examples/terragrunt.hcl)
  EOF

  type = map(
    # map keys: internal NACL "names"
    object({
      access = optional(object({
        ingress = optional(map(
          # map keys: quoted rule numbers (e.g., "100")
          object({
            cidr_block = string
            protocol   = optional(string)
            port       = optional(number)
            from_port  = optional(number)
            to_port    = optional(number)
          })
        ))
        egress = optional(map(
          # map keys: quoted rule numbers (e.g., "100")
          object({
            cidr_block = string
            protocol   = optional(string)
            port       = optional(number)
            from_port  = optional(number)
            to_port    = optional(number)
          })
        ))
      }))
      tags = optional(map(string))
    })
  )

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
  Map of Security Group names to config objects. For more info:
    - [`Security Groups` README](#security_groups)
    - [Usage example](examples/terragrunt.hcl)
  EOF

  type = map(
    # map keys: security group names
    object({
      description = string
      access = object({
        ingress = optional(list(
          object({
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
          })
        ))
        egress = optional(list(
          object({
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
          })
        ))
      })
      tags = optional(map(string))
    })
  )

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
