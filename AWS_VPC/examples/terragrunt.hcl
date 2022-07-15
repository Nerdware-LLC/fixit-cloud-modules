######################################################################
### EXAMPLE USAGE: AWS_VPC

/* As in any Terragrunt config, the inputs below may be all provided in a single
standalone config, or may be broken up over multiple configs and utilized via
include-blocks or the read_terragrunt_config() TG fn.  */

#---------------------------------------------------------------------
### Dependencies

dependency "peer_vpc" {
  config_path = "../../Management-Svcs-Account/VPC"
}

#---------------------------------------------------------------------
### Inputs

locals {
  vpc_cidr = "10.1.0.0/16"

  # Two AZs, each with one PUBLIC and one PRIVATE subnet
  subnet_cidrs = {
    # Subnets in us-east-2a
    public_subnet_A    = cidrsubnet(local.vpc_cidr, 8, 0)
    private_subnet_A   = cidrsubnet(local.vpc_cidr, 8, 1)
    intraOnly_subnet_A = cidrsubnet(local.vpc_cidr, 8, 2)

    # Subnets in us-east-2b
    public_subnet_B  = cidrsubnet(local.vpc_cidr, 8, 3)
    private_subnet_B = cidrsubnet(local.vpc_cidr, 8, 4)
  }

  peer_vpc = dependency.peer_vpc.outputs.VPC
}

inputs = {

  # VPC --------------------------------------------

  vpc = {
    cidr_block = local.vpc_cidr

    enable_dns_support   = true # <-- default: true
    enable_dns_hostnames = true # <-- default: true
    tags = {
      Name = "Foo_Development_VPC"
    }
  }

  # VPC PEERING ------------------------------------

  peering_request_vpc_ids = {

    # Request peering connection with Management-Svcs VPC
    "${local.peer_vpc.id}" = {
      peer_vpc_owner_account_id       = local.peer_vpc.owner_id
      allow_remote_vpc_dns_resolution = true # <-- default: true

      /* In this example, both vpc and peer_vpc are in the same region, so
      "peer_region" does not have to be provided here.

      Also, since this example VPC and the peer Management-Svcs VPC are owned
      by different accounts, the peering connection cannot be auto-accepted -
      it must be manually accepted by the peer VPC. Assuming the peer VPC is
      using the same VPC module, acceptance would be configured using the
      "peering_accept_connection_ids" input variable.  */
    }
  }

  # SUBNETS ----------------------------------------

  subnets = {
    # var.subnets map keys: subnet CIDRs

    # Subnets in us-east-2a

    "${local.subnet_cidrs.public_subnet_A}" = {
      type                    = "PUBLIC"
      availability_zone       = "us-east-2a"
      map_public_ip_on_launch = true # <-- default: false

      /* Since this AZ includes a PRIVATE subnet, we must have at least one PUBLIC
      subnet in the same AZ configured with "contains_nat_gateway" = true.      */
      contains_nat_gateway = true # <-- default: false

      tags = {
        Name = "Public_Subnet_A"
      }
    }
    "${local.subnet_cidrs.private_subnet_A}" = {
      type              = "PRIVATE"
      availability_zone = "us-east-2a"

      /* Use the "route_table" key to have a subnet use a particular route table.
      For PRIVATE subnets, the specified "route_table" must be one that uses a NAT
      gateway for its default route (0.0.0.0/0). Like all NAT-related resources,
      by default this module internally identifies these NAT-connected route tables
      using the CIDR of the PUBLIC subnet which contains the NAT gateway.

      Any PRIVATE subnets which are not provided with a "route_table" value shall
      be evenly distributed among all available NAT-connected route tables in their
      availability zone. Since this VPC only has 1 NAT-containing PUBLIC subnet in
      this PRIVATE subnet's AZ, there's a 100% chance this subnet will be associated
      with the route table identified by Public_Subnet_A's CIDR. Therefore, it's
      entirely unnecessary to explicitly provide the "route_table" value here, but
      it's included for the sake of clarity.                                    */
      route_table = local.subnet_cidrs.public_subnet_A

      tags = {
        Name = "Private_Subnet_A"
      }
    }
    "${local.subnet_cidrs.intraOnly_subnet_A}" = {
      type              = "INTRA-ONLY"
      availability_zone = "us-east-2a"

      /* INTRA-ONLY subnets are useful for workloads which don't require internet
      access, and/or are privacy-sensitive in nature. They can not be configured
      to use a public default route ("0.0.0.0/0"), but may use VPC endpoints and
      peering routes.                                                         */

      tags = {
        Name       = "IntraOnly_Subnet_A"
        Department = "Human-Resources"
        Purpose    = "Batch-Lambda workloads on employee health records"
      }
    }

    # Subnets in us-east-2b

    "${local.subnet_cidrs.public_subnet_B}" = {
      type                    = "PUBLIC"
      availability_zone       = "us-east-2b"
      map_public_ip_on_launch = true

      /* This AZ also includes a PRIVATE subnet, so again we must have at least one
      PUBLIC subnet in the same AZ configured with "contains_nat_gateway" = true. */
      contains_nat_gateway = true

      tags = {
        Name = "Public_Subnet_B"
      }
    }
    "${local.subnet_cidrs.private_subnet_B}" = {
      type              = "PRIVATE"
      availability_zone = "us-east-2b"

      /* Use the "network_acl" key to have a subnet use a particular network ACL. Any
      subnets which are not provided with a "network_acl" value shall by assigned to an
      NACL containing common rules which reflect the subnet "type".

      Note that no rules are merged into custom NACLs. All ingress/egress rules - including
      those for ephemeral ports - must be provided in custom NACL configs.  */
      network_acl = "Peered_Private_Subnet_NACL"

      tags = {
        Name = "Private_Subnet_B"
      }
    }
  }

  # ROUTE TABLES -----------------------------------

  route_tables = {
    # var.route_tables map keys: route table "names"

    /* Since our VPC will have a peering connection with the Management-Svcs VPC,
    we need to add a route to at least one route table in order for traffic to be
    routable to the peer VPC. To demonstrate how this can be achieved in a variety
    of configurations, we have three examples all of which add the same VPC-peering
    route:

      1. The module-provided Subnet-Type route table for PUBLIC subnets, "Public_Subnets_RouteTable".
      2. The route table with a default route (0.0.0.0/0) set to the NAT located in Public_Subnet_A.
      3. An entirely custom route table, "My_Custom_RouteTable".                 */

    # RT Example 1
    Public_Subnets_RouteTable = {
      /* Here we add the peering route to the module-provided Subnet-Type route
      table for PUBLIC subnets. Note that changing this RT will impact all PUBLIC
      subnets that aren't configured to use a custom route table. If this behavior
      is undesirable, use one or more custom route tables instead (see RT Example 3). */
      routes = {
        # "routes" map keys: CIDRs of route destinations

        "${local.peer_vpc.cidr_block}" = {
          /* A route for a peering connection can be configured in one of two ways:

            1. If VPC is the peering REQUESTER, use "peering_request_vpc_id"
            2. If VPC is the peering ACCEPTER, use "peering_connection_id"

          In this example, our VPC is the REQUESTER, so we use the same VPC ID in
          "peering_request_vpc_id" that was used in "var.peering_request_vpc_ids". */
          peering_request_vpc_id = local.peer_vpc.id
        }
      }

      # You can also add tags to any route table - with or without custom routes.
      tags = {
        Name = "Public_Subnets_RouteTable"
      }
    }

    # RT Example 2
    "${local.subnet_cidrs.public_subnet_A}" = {
      /* PRIVATE subnet route tables all have a default route (0.0.0.0/0) which points
      to a NAT gateway. Like the NAT gateways themselves, these NAT-connected PRIVATE
      subnet route tables are internally identified by the CIDR of the PUBLIC subnet
      in which the NAT is placed, so the below configs will be applied to the route
      table which has a default route set to the NAT gateway in Public_Subnet_A.   */
      routes = {
        "${local.peer_vpc.cidr_block}" = {
          peering_request_vpc_id = local.peer_vpc.id
        }
      }
    }

    # RT Example 3
    My_Custom_RouteTable = {
      /* Use custom route tables when two or more subnets will have the same default
      route (0.0.0.0/0), and you'd like only a subset of those subnets to have certain
      routing rules (e.g., a VPC-peering route). When this is the case, place the custom
      route configs in a custom route table with a "name" of your choosing, and configure
      one or more subnets to use the custom RT by setting their "route_table" property to
      the name of your custom RT.

      Type-specific notes:

        - For PUBLIC subnets, you can always add custom routes (e.g., VPC-peering) to the
          "Public_Subnets_RouteTable" as shown in RT Example 1, but such changes will by
          default impact every public subnet.

        - For PRIVATE subnets, you can always add custom routes to a NAT-connected route
          table by using it's identifying CIDR, but again such changes will by default
          impact every private subnet associated with that route table. Note that in this
          regard, it does not matter whether the private subnets were explicitly associated
          with the route table via the "route_table" property or dynamically assigned via
          the same-AZ even-distribution formula.
      */
      routes = {
        "${local.peer_vpc.cidr_block}" = {
          peering_request_vpc_id = local.peer_vpc.id
        }
      }
    }
  }

  # NETWORK ACLs -----------------------------------

  network_acls = {
    # var.network_acls map keys: NACL "names"

    /* In this example, an ingress rule is added to allow SSH access from an on-prem
    office IP address "123.123.123.123/32". This rule will be merged in with the default
    Subnet-Type rules provided for Public_Subnets_NACL, and will by default impact all
    public subnets. If this is not desirable, a custom NACL should be used instead. */
    Public_Subnets_NACL = {
      access = {
        ingress = {
          "300" = {
            cidr_block = "123.123.123.123/32"
            port       = 22    # use "port" if "from_port" and "to_port" are the same
            protocol   = "tcp" # default: "tcp"
          }
        }
      }
      # You can also add tags to any NACL - with or without custom access rules.
      tags = {
        Name = "Public_Subnets_NACL"
      }
    }

    /* Here, the module-provided egress rule for ephemeral ports is overwritten to use a
    non-default range (ingress/egress default range for public and private subnets: 1024-65535).
    This rule will replace rule number 500 for Private_Subnets_NACL, and will by default impact
    all private subnets. If this is not desirable, a custom NACL should be used instead.   */
    Private_Subnets_NACL = {
      access = {
        egress = {
          "500" = {
            cidr_block = "0.0.0.0/0"
            from_port  = 1337
            to_port    = 60420
          }
        }
      }
    }

    /* Use custom NACLs to apply access rules to only a subset of subnets of a given type.
    Place the custom access rule configs in a custom NACL with a "name" of your choosing,
    and configure one or more subnets to use the custom NACL by setting their "network_acl"
    property to the name of your custom NACL.

    Note that no rules are merged into custom NACLs. All ingress/egress rules - including
    those for ephemeral ports - must be provided in custom NACL configs.               */
    Peered_Private_Subnet_NACL = {
      access = {
        /* Rule numbering convention used in the below example:
            - 2xx   indicates HTTPS
            - 5xx   indicates ephemeral ports
            - x00   indicates traffic with Public_Subnet_A
            - x10   indicates traffic with Management-Svcs VPC peer
        */
        ingress = {
          "200" = { # HTTPS from Public_Subnet_A
            cidr_block = local.subnet_cidrs.public_subnet_A
            port       = 443
          }
          "210" = { # HTTPS from peer: Management-Svcs VPC
            cidr_block = local.peer_vpc.cidr_block
            port       = 443
          }
          "510" = { # Ephemeral ports ingress from peer: Management-Svcs VPC
            cidr_block = local.peer_vpc.cidr_block
            from_port  = 1024
            to_port    = 65535
          }
        }
        egress = {
          "210" = { # HTTPS to peer: Management-Svcs VPC
            cidr_block = local.peer_vpc.cidr_block
            port       = 443
          }
          "500" = { # Ephemeral ports egress to Public_Subnet_A
            cidr_block = local.subnet_cidrs.public_subnet_A
            from_port  = 1024
            to_port    = 65535
          }
          "510" = { # Ephemeral ports egress to peer: Management-Svcs VPC
            cidr_block = local.peer_vpc.cidr_block
            from_port  = 1024
            to_port    = 65535
          }
        }
      }
    }
  }

  # SECURITY GROUPS --------------------------------

  security_groups = {
    # var.security_groups map keys: security group names

    Foo_Webservers_SecGroup = {
      description = "Used by Nginx and Apache webservers."
      access = {
        ingress = [
          {
            # When "from_port" and "to_port" are the same, you can simply provide just "port"
            description = "HTTPS ingress for global customer access"
            port        = 443
            cidr_blocks = ["0.0.0.0/0"]
          }
        ]
        egress = [
          {
            /* Use "peer_security_group" to configure ingress/egress rules which
            target other security groups in the same config.  */
            description         = "HTTPS to Foo_API_Gateway_SecGroup"
            port                = 443
            peer_security_group = "Foo_API_Gateway_SecGroup"
          }
        ]
      }
    }

    Foo_API_Gateway_SecGroup = {
      description = "Used by Apollo-GraphQL federated gateway."
      access = {
        ingress = [
          {
            description         = "HTTPS from Foo_Webservers_SecGroup"
            port                = 443
            peer_security_group = "Foo_Webservers_SecGroup"
          }
        ]
        egress = [
          {
            description         = "HTTPS to Foo_API_MicroServices_SecGroup"
            port                = 443
            peer_security_group = "Foo_API_MicroServices_SecGroup"
          }
        ]
      }
    }

    Foo_API_MicroServices_SecGroup = {
      description = "Used by API microservices."
      access = {
        ingress = [
          {
            description         = "HTTPS from Foo_API_Gateway_SecGroup"
            port                = 443
            peer_security_group = "Foo_API_Gateway_SecGroup"
          },
          {
            /* If instances within the same security group should be able to
            communicate with one another, use the "self" property.        */
            description = "HTTPS from other API microservices"
            port        = 443
            self        = true
          }
        ]
        egress = [
          {
            description = "HTTPS to other API microservices"
            port        = 443
            self        = true
          },
          {
            description         = "MySQL-protocol to Foo_Databases_SecGroup"
            port                = 3306
            peer_security_group = "Foo_Databases_SecGroup"
          }
        ]
      }
    }

    Foo_Databases_SecGroup = {
      description = "Used by MySQL r/w instances."
      access = {
        ingress = [
          {
            description         = "MySQL-protocol from Foo_API_MicroServices_SecGroup"
            port                = 3306
            peer_security_group = "Foo_API_MicroServices_SecGroup"
          }
        ]
        egress = []
      }
    }
  }

  # VPC ENDPOINTS ----------------------------------

  vpc_endpoints = {
    s3 = {
      type         = "Gateway"
      route_tables = ["Private_Subnets_NACL"]
    }
  }

  # MISC RESOURCE TAGS -----------------------------

  internet_gateway_tags = {
    Name = "Internet_Gateway"
  }

  /* NAT gateways are internally identified by the CIDR of the PUBLIC subnet in
  which they're placed. The same is true for NAT gateway elastic IPs, as well as
  each NAT's route table (one route table is created for each NAT, which is used
  for the "0.0.0.0/0" default route).  */

  nat_gateway_tags = {
    # Tags for the NAT in public subnet A
    "${local.subnet_cidrs.public_subnet_A}" = {
      Name = "Foo_NAT_Gateway"
    }
  }

  nat_gateway_elastic_ip_tags = {
    # Tags for the NAT EIP in public subnet B
    "${local.subnet_cidrs.public_subnet_B}" = {
      Name = "Bar_NAT_Gateway_Elastic_IP"
    }
  }

  default_route_table_tags    = { Name = "Default_RouteTable" }
  default_network_acl_tags    = { Name = "Default_NACL" }
  default_security_group_tags = { Name = "Default_SecurityGroup" }
}

######################################################################
