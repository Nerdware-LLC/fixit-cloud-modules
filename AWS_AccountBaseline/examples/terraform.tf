######################################################################
### EXAMPLE USAGE: AWS_AccountBaseline

module "AWS_AccountBaseline" {
  source = "git@github.com:Nerdware-LLC/fixit-cloud-modules.git//AWS_AccountBaseline"

  # It's not recommended to override the default s3_account_public_access_block values.
  # Totally fine to not provide any inputs. If you like, tag the default VPC resources:

  default_vpc_component_tags = {
    default_vpc            = { Name = "Default_VPC", isLockedDown = "true" }
    default_route_table    = { Name = "Default_RouteTable", isLockedDown = "true" }
    default_network_acl    = { Name = "Default_NACL", isLockedDown = "true" }
    default_security_group = { Name = "Default_SecGrp", isLockedDown = "true" }
  }
}

######################################################################
