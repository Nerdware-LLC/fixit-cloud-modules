######################################################################
### INPUT VARIABLES
#---------------------------------------------------------------------
### VPC

variable "vpc" {
  description = "Config object for the VPC; all optional bools default to \"true\"."
  type = object({
    cidr_block           = string
    enable_dns_support   = optional(bool)
    enable_dns_hostnames = optional(bool)
    tags                 = optional(map(string))
  })
  validation {
    condition     = can(cidrsubnet(var.vpc.cidr_block, 4, 0))
    error_message = "Must be a valid CIDR block string (e.g., \"10.1.0.0/16\")."
  }
}

#---------------------------------------------------------------------
### Subnets

variable "subnets" {
  description = <<-EOF
  Map of subnet config objects with quoted CIDR strings as keys (e.g., "127.1.0.0/24").
  All CIDR blocks must fit within the given VPC, and must not overlap with one another.
  The "egress_destination" property can be "INTERNET_GATEWAY", "NAT_GATEWAY", a valid
  CIDR block string pointing to another VPC, or "NONE". Support for other destination
  types, such as "VIRTUAL_PRIVATE_GATEWAY", will be added in the future. If set to "NONE",
  egress traffic will not be able to leave the subnet. Aside from determining which route
  table each subnet is associated with, the values of this property across all subnets
  collectively determine which gateways and route tables get created within the VPC.
  The property "contains_nat_gateway" is optional (with a default value of "false"), and
  determines in which subnet - if any - the NAT gateway should be placed. Only one subnet
  can have this property set to "true"; if no subnets have "contains_nat_gateway" set to
  "true", the NAT gateway and its associated elastic IP address shall be skipped.
  EOF
  type = map(object({
    availability_zone       = string
    egress_destination      = string
    map_public_ip_on_launch = optional(bool)
    contains_nat_gateway    = optional(bool)
    tags                    = optional(map(string))
  }))
  # Ensure all "egress_destination" values are one of the allowed enum values.
  validation {
    condition = alltrue([
      for egress_dest in values(var.subnets)[*].egress_destination : anytrue([
        contains(["NONE", "INTERNET_GATEWAY", "NAT_GATEWAY"], egress_dest),
        can(cidrsubnet(egress_dest, 4, 0)) # checks if valid CIDR for VPC dests
      ])
    ])
    error_message = "All \"egress_destination\" values must be either \"INTERNET_GATEWAY\", \"NAT_GATEWAY\", \"NONE\", or a valid CIDR block string (e.g., \"127.1.0.0/24\")."
  }
  # If any subnets are meant to be private (egress_destination = NAT), then 1 subnet must be designated for a NAT gw.
  validation {
    condition = anytrue([
      alltrue([for egress_dest in values(var.subnets)[*].egress_destination : egress_dest != "NAT_GATEWAY"]),
      1 == length([for sub in values(var.subnets) : sub if lookup(sub, "contains_nat_gateway", false)])
    ]) # We don't want the below err msg shown if user passed MORE than 1 contains_nat_gateway=true, hence the "length() >= 1" in the above ternary.
    error_message = "To route egress traffic to a NAT gateway, exactly 1 subnet must have \"contains_nat_gateway\" = \"true\"."
  }
}

#---------------------------------------------------------------------
### Gateway Tags:

variable "gateway_tags" {
  description = "Config object for VPC gateway resource tags."
  type = object({
    internet_gateway       = optional(map(string))
    nat_gateway            = optional(map(string))
    nat_gateway_elastic_ip = optional(map(string))
  })
}

#---------------------------------------------------------------------
### Route Table Tags:

variable "route_table_tags" {
  description = <<-EOF
  Map of route table resource tags, with subnet egress destinations as keys
  (see the description for "var.subnets" for more info). The keys must either
  be "INTERNET_GATEWAY", "NAT_GATEWAY", or a valid CIDR block quoted string
  pointing to another VPC. Support for other destination types, such as
  "VIRTUAL_PRIVATE_GATEWAY", will be added in the future.
  EOF
  type        = map(map(string))
  default = {
    INTERNET_GATEWAY = {}
    NAT_GATEWAY      = {}
  }
  # Ensure all keys are one of the allowed enum values.
  validation {
    condition = alltrue([
      for egress_dest in keys(var.route_table_tags) : anytrue([
        contains(["INTERNET_GATEWAY", "NAT_GATEWAY"], egress_dest),
        can(cidrsubnet(egress_dest, 4, 0)) # checks if valid CIDR for VPC dests
      ])
    ])
    error_message = "All keys must be either \"INTERNET_GATEWAY\", \"NAT_GATEWAY\", or a valid CIDR block string (e.g., \"127.1.0.0/24\")."
  }
}

#---------------------------------------------------------------------
### VPC Default Component Variables:

variable "default_resource_tags" {
  description = <<-EOF
  In accordance with best practices, this module locks down the VPC's default
  components to ensure all ingress/egress traffic only uses infrastructure with
  purposefully-designed rules and configs. Default subnets must be deleted manually
  - they cannot be removed via Terraform. This variable allows you to customize the
  tags on these "default" network components.
  EOF
  type = object({
    default_route_table    = optional(map(string))
    default_network_acl    = optional(map(string))
    default_security_group = optional(map(string))
  })
  default = {
    default_route_table    = null
    default_network_acl    = null
    default_security_group = null
  }
}

#---------------------------------------------------------------------
### Network ACL Variables

variable "network_acl_configs" {
  description = <<-EOF
  List of config objects for Network ACL resources. For ingress/egress rule config objects,
  instead of providing separate "from_port" and "to_port" args, you can alternatively provide
  just "port" which will map to both. You can also pass a string value like "HTTPS" or "Redis"
  (case-insensitive) to the "default_port" arg to have the default port of the protocol/service
  mapped to both. Refer to the README for a list of supported arguments for "default_port". If
  you need the cidr_block of a particular AWS service, like EC2 Instance Connect, you can pass
  cidr_block = "EC2_INSTANCE_CONNECT". Please refer to the README to for a list of supported
  AWS services for "cidr_block".
  EOF
  type = list(object({
    subnet_cidrs = list(string)
    access = optional(object({
      ingress = optional(list(object({
        rule_number  = number
        cidr_block   = string
        protocol     = optional(string)
        default_port = optional(string)
        port         = optional(number)
        from_port    = optional(number)
        to_port      = optional(number)
      })))
      egress = optional(list(object({
        rule_number  = number
        cidr_block   = string
        protocol     = optional(string)
        default_port = optional(string)
        port         = optional(number)
        from_port    = optional(number)
        to_port      = optional(number)
      })))
    }))
    tags = optional(map(string))
  }))
  validation {
    condition = alltrue([
      for rule in flatten([var.network_acl_configs[*].access.ingress, var.network_acl_configs[*].access.egress]) : anytrue([
        # Ensure all rules contain one of the following: default_port, OR port, OR (from_port AND to_port)
        can(rule.from_port) && can(rule.to_port),
        can(rule.port),
        can(rule.default_port)
      ])
    ])
    error_message = "Invalid port-defining properties on one or more network ACL rule config objects."
  }
}

#---------------------------------------------------------------------
### Security Group Variables

variable "security_groups" {
  description = <<-EOF
  Map of Security Group name keys pointing to config object values. For ingress/egress rule
  config objects, instead of providing separate "from_port" and "to_port" arguments, you can
  alternatively just provide "port" which will map to both. For SecGrp ingress/egress rules
  which need to point to another Security Group, use the "peer_security_group" key with the
  value set to the name of the target SecGrp. If you need the cidr_blocks of a particular AWS
  service, like EC2 Instance Connect, you can set "aws_service" = "EC2_INSTANCE_CONNECT".
  Please refer to the README for a list of supported arguments for "aws_service".
  EOF
  type = list(object({
    name        = string
    description = string
    tags        = optional(map(string))
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
  }))
  validation {
    condition = alltrue(flatten([
      for sec_grp in var.security_groups : [
        for access_type, rule_list in sec_grp.access : [
          for rule in rule_list : alltrue([
            # Ensure all rules contain "port" OR ("from_port" AND "to_port")
            anytrue([
              can(rule.from_port) && can(rule.to_port),
              can(rule.port)
            ]),
            # Ensure all rules contain exactly one of the following: peer_security_group_id OR peer_security_group OR aws_service OR cidr_blocks OR self
            1 == length([
              for rule_key in ["peer_security_group_id", "peer_security_group", "aws_service", "cidr_blocks", "self"] : rule_key
              if alltrue([
                can(rule[rule_key]),              # check rule param existence
                rule_key == "peer_security_group" # for peer_secgrp, ensure named SecGrp exists
                ? contains(var.security_groups[*].name, lookup(rule, rule_key, ""))
                : true
              ])
            ])
          ])
        ]
      ]
    ]))
    error_message = "Invalid combination of properties on one or more security group rule config objects."
  }
}

######################################################################
