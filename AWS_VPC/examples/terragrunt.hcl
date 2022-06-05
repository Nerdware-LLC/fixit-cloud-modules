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
    public_subnet_A = cidrsubnet(local.vpc_cidr, 8, 0)
    private_subnet_A = cidrsubnet(local.vpc_cidr, 8, 1)

    # Subnets in us-east-2b
    public_subnet_B = cidrsubnet(local.vpc_cidr, 8, 2)
    private_subnet_B = cidrsubnet(local.vpc_cidr, 8, 3)
  }

  peer_vpc = dependency.peer_vpc.outputs.VPC
}

inputs = {

  # VPC --------------------------------------------

  vpc = {
    cidr_block = local.vpc_cidr
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
        "peering_accept_connection_ids" property.                        */
      }

    }
    enable_dns_support   = true # <-- default: true
    enable_dns_hostnames = true # <-- default: true
    tags = {
      Name = "Foo_Development_VPC"
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
      type                    = "PRIVATE"
      availability_zone       = "us-east-2a"
      # TODO maybe use custom network_acl
      tags = {
        Name = "Private_Subnet_A"
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
      type                    = "PRIVATE"
      availability_zone       = "us-east-2b"
      # TODO maybe use custom network_acl
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
      is undesirable, use one or more custom route tables instead.             */
      routes = {
        # "routes" map keys: CIDRs of route destinations

        "${local.peer_vpc.cidr_block}" = {
          /* A route for a peering connection can be configured in one of two ways:

            1. If VPC is the peering REQUESTER, use "peering_request_vpc_id"
            2. If VPC is the peering ACCEPTER, use "peering_connection_id"

          In this example, our VPC is the REQUESTER, so we use the same VPC ID in
          "peering_request_vpc_id" that was used in "var.vpc.peering_request_vpc_ids". */
          peering_request_vpc_id = local.peer_vpc.id
        }
      }
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
      table which has a default route set to the NAT in Public_Subnet_A.         */
      routes = {
        "${local.peer_vpc.cidr_block}" = {
          peering_request_vpc_id = local.peer_vpc.id
        }
      }
    }

    # RT Example 3
    My_Custom_RouteTable = {

    }
  }

  # NETWORK ACLs -----------------------------------

  network_acls = {
    # var.network_acls map keys: NACL "names"

    # FIXME
  }

  # SECURITY GROUPS --------------------------------

  security_groups = {
    Foo_Webservers_SecGroup = {
      description = "HTTP/S from anywhere, HTTPS to Foo_API_MicroServices_SecGroup."
      access = {
        ingress = [
          {
            description = "HTTPS ingress for global customer access"
            port        = 443
            cidr_blocks = ["0.0.0.0/0"]
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
      description = "HTTPS from Foo_Webservers_SecGroup, MySQL-protocol to Foo_Databases_SecGroup."
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
            description         = "MySQL-protocol to Foo_Databases_SecGroup"
            port                = 3306
            peer_security_group = "Foo_Databases_SecGroup"
          }
        ]
      }
    }
    Foo_Databases_SecGroup = {
      description = "MySQL-protocol from Foo_API_MicroServices_SecGroup."
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
