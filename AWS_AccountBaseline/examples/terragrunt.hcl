######################################################################
### EXAMPLE USAGE: AWS_AccountBaseline

/* As in any Terragrunt configuration, the inputs below can be
provided in a single standalone resource config, or may be broken up
across multiple resource configs and utilized with a combination of
include-blocks and/or the read_terragrunt_config() Terragrunt fn. */

#---------------------------------------------------------------------
### Inputs

inputs = {
  # Totally fine to not provide any inputs. If you like, tag the default VPC resources:

  default_vpc_component_tags = {
    default_vpc            = { Name = "Default_VPC", isLockedDown = "true" }
    default_route_table    = { Name = "Default_RouteTable", isLockedDown = "true" }
    default_network_acl    = { Name = "Default_NACL", isLockedDown = "true" }
    default_security_group = { Name = "Default_SecGrp", isLockedDown = "true" }
  }
}

######################################################################
