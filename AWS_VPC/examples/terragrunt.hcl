######################################################################
### EXAMPLE USAGE: AWS_VPC

/* As in any Terragrunt config, the inputs below may be all provided in
a single standalone config, or may be broken up over multiple configs and
utilized via include-blocks or the read_terragrunt_config() TG fn.  */

#---------------------------------------------------------------------
### Dependencies

dependency "peer_vpc" {
  config_path = "../../Management-Svcs-Account/VPC"
}

#---------------------------------------------------------------------
### Inputs

locals {
  vpc_cidr = "10.1.0.0/16"
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

        /* If both vpc and peer_vpc are in the same region,
        "peer_region" need not be provided.  */

        /* Since these VPCs are owned by different accounts,
        the peering connection cannot be auto-accepted, it must
        be manually accepted by the peer VPC.  */
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
    "${cidrsubnet(local.vpc_cidr, 8, 0)}" = {
      type                    = "PUBLIC"
      availability_zone       = "us-east-2a"
      map_public_ip_on_launch = true # <-- default: false

      /* Since this VPC includes a PRIVATE subnet, we must have
      at least 1 PUBLIC subnet in the same AZ configured with
      "contains_nat_gateway" = true (default: false).  */
      contains_nat_gateway = true
      tags = {
        Name = "Foo_Public_Subnet"
      }
    }
    "${cidrsubnet(local.vpc_cidr, 8, 1)}" = {
      type                    = "PRIVATE"
      availability_zone       = "us-east-2a"
      # TODO maybe use custom_network_acl
      tags = {
        Name = "Foo_Private_Subnet"
      }
    }
  }

  # ROUTE TABLES -----------------------------------

  route_tables = {
    # var.route_tables map keys: route table "names"
    Public_Subnets_RouteTable = {
      /* Since our VPC will have a peering connection with the
      Management-Svcs VPC, we need to add a route to at least one
      route table in order for traffic to be routable to the peer
      VPC. Here this is accomplished by adding a route to the
      module-provided Subnet-Type route table for PUBLIC subnets.

      A route for a peering connection can be configured in one of two ways:
        1. If VPC is the peering REQUESTER, use "peering_request_vpc_id"
        2. If VPC is the peering ACCEPTER, use "peering_connection_id"

      In this example, our VPC is the REQUESTER, so we use the same
      VPC ID in "peering_request_vpc_id" that was used in
      "var.vpc.peering_request_vpc_ids"  */
      routes = {
        # "routes" map keys: CIDRs of route destinations
        "${local.peer_vpc.cidr_block}" = {
          peering_request_vpc_id = local.peer_vpc.id
        }
      }
    }
  }

  # NETWORK ACLs -----------------------------------

  network_acls = {
    # var.network_acls map keys: NACL "names"
  }

  # SECURITY GROUPS --------------------------------

  security_groups = {
    Foo_Webservers_SecGroup = {
      description = "HTTP/S from anywhere, HTTPS to Foo_API_MicroServices_SecGroup."
      access = {
        ingress = [
          {
            description = "HTTPS ingress for user access"
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
      description = "HTTPS from Foo_Webservers_SecGroup, HTTPS to Foo_Databases_SecGroup."
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
            description         = "HTTPS:3306 to Foo_Databases_SecGroup"
            port                = 3306
            peer_security_group = "Foo_Databases_SecGroup"
          }
        ]
      }
    }
    Foo_Databases_SecGroup = {
      description = "HTTPS:3306 from Foo_API_MicroServices_SecGroup."
      access = {
        ingress = [
          {
            description         = "HTTPS:3306 from Foo_API_MicroServices_SecGroup"
            port                = 3306
            peer_security_group = "Foo_API_MicroServices_SecGroup"
          }
        ]
        egress = []
      }
    }
  }

  # MISC RESOURCE TAGS -----------------------------

  internet_gateway_tags       = { Name = "Internet_Gateway" }
  default_route_table_tags    = { Name = "Default_RouteTable" }
  default_network_acl_tags    = { Name = "Default_NACL" }
  default_security_group_tags = { Name = "Default_SecurityGroup" }
}

######################################################################
