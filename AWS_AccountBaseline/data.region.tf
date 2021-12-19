######################################################################
### DATA - REGION

data "aws_region" "current" {}

data "aws_regions" "available" {
  all_regions = false

  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  aws_region  = data.aws_region.current.name
  all_regions = data.aws_regions.available.names
}

######################################################################
