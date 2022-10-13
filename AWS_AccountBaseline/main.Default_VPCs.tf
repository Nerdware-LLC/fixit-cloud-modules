######################################################################
### Default VPC Components
######################################################################

/* NOTES:
  - On all aws_default_vpc resources, the TFSec rule "aws-vpc-no-default-vpc" is ignored
    since the purpose of including these default VPC resource blocks is to prevent usage
    of default VPCs and deny all traffic within them.

  - All aws_default_route_table, aws_default_network_acl, and aws_default_security_group
    resources are configured without any routes to ensure they deny all ingress and egress
    traffic, thereby ensuring the only traffic permitted to move through our VPCs is that
    which has been explicitly and purposefully allowed.

  - All aws_default_network_acl resource blocks are configured with a lifecycle rule which
    ignores changes to "subnet_ids"; see below link for explanation.
    https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_network_acl#managing-subnets-in-a-default-network-acl
*/

######################################################################
### us-east-2 (HOME REGION USES IMPLICIT/DEFAULT PROVIDER)

#tfsec:ignore:aws-vpc-no-default-vpc
resource "aws_default_vpc" "us-east-2" {
  tags = var.default_vpc_component_tags.default_vpc
}

resource "aws_default_route_table" "us-east-2" {
  default_route_table_id = aws_default_vpc.us-east-2.default_route_table_id
  route                  = []
  tags                   = var.default_vpc_component_tags.default_route_table
}

resource "aws_default_network_acl" "us-east-2" {
  default_network_acl_id = aws_default_vpc.us-east-2.default_network_acl_id
  tags                   = var.default_vpc_component_tags.default_network_acl

  lifecycle {
    ignore_changes = [subnet_ids]
  }
}

resource "aws_default_security_group" "us-east-2" {
  vpc_id = aws_default_vpc.us-east-2.id
  tags   = var.default_vpc_component_tags.default_security_group
}

#---------------------------------------------------------------------
### ap-northeast-1

#tfsec:ignore:aws-vpc-no-default-vpc
resource "aws_default_vpc" "ap-northeast-1" {
  provider = aws.ap-northeast-1

  tags = var.default_vpc_component_tags.default_vpc
}

resource "aws_default_route_table" "ap-northeast-1" {
  provider = aws.ap-northeast-1

  default_route_table_id = aws_default_vpc.ap-northeast-1.default_route_table_id
  route                  = []
  tags                   = var.default_vpc_component_tags.default_route_table
}

resource "aws_default_network_acl" "ap-northeast-1" {
  provider = aws.ap-northeast-1

  default_network_acl_id = aws_default_vpc.ap-northeast-1.default_network_acl_id
  tags                   = var.default_vpc_component_tags.default_network_acl

  lifecycle {
    ignore_changes = [subnet_ids]
  }
}

resource "aws_default_security_group" "ap-northeast-1" {
  provider = aws.ap-northeast-1

  vpc_id = aws_default_vpc.ap-northeast-1.id
  tags   = var.default_vpc_component_tags.default_security_group
}

#---------------------------------------------------------------------
###

#tfsec:ignore:aws-vpc-no-default-vpc
resource "aws_default_vpc" "ap-northeast-2" {
  provider = aws.ap-northeast-2

  tags = var.default_vpc_component_tags.default_vpc
}

resource "aws_default_route_table" "ap-northeast-2" {
  provider = aws.ap-northeast-2

  default_route_table_id = aws_default_vpc.ap-northeast-2.default_route_table_id
  route                  = []
  tags                   = var.default_vpc_component_tags.default_route_table
}

resource "aws_default_network_acl" "ap-northeast-2" {
  provider = aws.ap-northeast-2

  default_network_acl_id = aws_default_vpc.ap-northeast-2.default_network_acl_id
  tags                   = var.default_vpc_component_tags.default_network_acl

  lifecycle {
    ignore_changes = [subnet_ids]
  }
}

resource "aws_default_security_group" "ap-northeast-2" {
  provider = aws.ap-northeast-2

  vpc_id = aws_default_vpc.ap-northeast-2.id
  tags   = var.default_vpc_component_tags.default_security_group
}

#---------------------------------------------------------------------
###

#tfsec:ignore:aws-vpc-no-default-vpc
resource "aws_default_vpc" "ap-northeast-3" {
  provider = aws.ap-northeast-3

  tags = var.default_vpc_component_tags.default_vpc
}

resource "aws_default_route_table" "ap-northeast-3" {
  provider = aws.ap-northeast-3

  default_route_table_id = aws_default_vpc.ap-northeast-3.default_route_table_id
  route                  = []
  tags                   = var.default_vpc_component_tags.default_route_table
}

resource "aws_default_network_acl" "ap-northeast-3" {
  provider = aws.ap-northeast-3

  default_network_acl_id = aws_default_vpc.ap-northeast-3.default_network_acl_id
  tags                   = var.default_vpc_component_tags.default_network_acl

  lifecycle {
    ignore_changes = [subnet_ids]
  }
}

resource "aws_default_security_group" "ap-northeast-3" {
  provider = aws.ap-northeast-3

  vpc_id = aws_default_vpc.ap-northeast-3.id
  tags   = var.default_vpc_component_tags.default_security_group
}

#---------------------------------------------------------------------
###

#tfsec:ignore:aws-vpc-no-default-vpc
resource "aws_default_vpc" "ap-south-1" {
  provider = aws.ap-south-1

  tags = var.default_vpc_component_tags.default_vpc
}

resource "aws_default_route_table" "ap-south-1" {
  provider = aws.ap-south-1

  default_route_table_id = aws_default_vpc.ap-south-1.default_route_table_id
  route                  = []
  tags                   = var.default_vpc_component_tags.default_route_table
}

resource "aws_default_network_acl" "ap-south-1" {
  provider = aws.ap-south-1

  default_network_acl_id = aws_default_vpc.ap-south-1.default_network_acl_id
  tags                   = var.default_vpc_component_tags.default_network_acl

  lifecycle {
    ignore_changes = [subnet_ids]
  }
}

resource "aws_default_security_group" "ap-south-1" {
  provider = aws.ap-south-1

  vpc_id = aws_default_vpc.ap-south-1.id
  tags   = var.default_vpc_component_tags.default_security_group
}

#---------------------------------------------------------------------
###

#tfsec:ignore:aws-vpc-no-default-vpc
resource "aws_default_vpc" "ap-southeast-1" {
  provider = aws.ap-southeast-1

  tags = var.default_vpc_component_tags.default_vpc
}

resource "aws_default_route_table" "ap-southeast-1" {
  provider = aws.ap-southeast-1

  default_route_table_id = aws_default_vpc.ap-southeast-1.default_route_table_id
  route                  = []
  tags                   = var.default_vpc_component_tags.default_route_table
}

resource "aws_default_network_acl" "ap-southeast-1" {
  provider = aws.ap-southeast-1

  default_network_acl_id = aws_default_vpc.ap-southeast-1.default_network_acl_id
  tags                   = var.default_vpc_component_tags.default_network_acl

  lifecycle {
    ignore_changes = [subnet_ids]
  }
}

resource "aws_default_security_group" "ap-southeast-1" {
  provider = aws.ap-southeast-1

  vpc_id = aws_default_vpc.ap-southeast-1.id
  tags   = var.default_vpc_component_tags.default_security_group
}

#---------------------------------------------------------------------
###

#tfsec:ignore:aws-vpc-no-default-vpc
resource "aws_default_vpc" "ap-southeast-2" {
  provider = aws.ap-southeast-2

  tags = var.default_vpc_component_tags.default_vpc
}

resource "aws_default_route_table" "ap-southeast-2" {
  provider = aws.ap-southeast-2

  default_route_table_id = aws_default_vpc.ap-southeast-2.default_route_table_id
  route                  = []
  tags                   = var.default_vpc_component_tags.default_route_table
}

resource "aws_default_network_acl" "ap-southeast-2" {
  provider = aws.ap-southeast-2

  default_network_acl_id = aws_default_vpc.ap-southeast-2.default_network_acl_id
  tags                   = var.default_vpc_component_tags.default_network_acl

  lifecycle {
    ignore_changes = [subnet_ids]
  }
}

resource "aws_default_security_group" "ap-southeast-2" {
  provider = aws.ap-southeast-2

  vpc_id = aws_default_vpc.ap-southeast-2.id
  tags   = var.default_vpc_component_tags.default_security_group
}

#---------------------------------------------------------------------
###

#tfsec:ignore:aws-vpc-no-default-vpc
resource "aws_default_vpc" "ca-central-1" {
  provider = aws.ca-central-1

  tags = var.default_vpc_component_tags.default_vpc
}

resource "aws_default_route_table" "ca-central-1" {
  provider = aws.ca-central-1

  default_route_table_id = aws_default_vpc.ca-central-1.default_route_table_id
  route                  = []
  tags                   = var.default_vpc_component_tags.default_route_table
}

resource "aws_default_network_acl" "ca-central-1" {
  provider = aws.ca-central-1

  default_network_acl_id = aws_default_vpc.ca-central-1.default_network_acl_id
  tags                   = var.default_vpc_component_tags.default_network_acl

  lifecycle {
    ignore_changes = [subnet_ids]
  }
}

resource "aws_default_security_group" "ca-central-1" {
  provider = aws.ca-central-1

  vpc_id = aws_default_vpc.ca-central-1.id
  tags   = var.default_vpc_component_tags.default_security_group
}

#---------------------------------------------------------------------
###

#tfsec:ignore:aws-vpc-no-default-vpc
resource "aws_default_vpc" "eu-north-1" {
  provider = aws.eu-north-1

  tags = var.default_vpc_component_tags.default_vpc
}

resource "aws_default_route_table" "eu-north-1" {
  provider = aws.eu-north-1

  default_route_table_id = aws_default_vpc.eu-north-1.default_route_table_id
  route                  = []
  tags                   = var.default_vpc_component_tags.default_route_table
}

resource "aws_default_network_acl" "eu-north-1" {
  provider = aws.eu-north-1

  default_network_acl_id = aws_default_vpc.eu-north-1.default_network_acl_id
  tags                   = var.default_vpc_component_tags.default_network_acl

  lifecycle {
    ignore_changes = [subnet_ids]
  }
}

resource "aws_default_security_group" "eu-north-1" {
  provider = aws.eu-north-1

  vpc_id = aws_default_vpc.eu-north-1.id
  tags   = var.default_vpc_component_tags.default_security_group
}

#---------------------------------------------------------------------
###

#tfsec:ignore:aws-vpc-no-default-vpc
resource "aws_default_vpc" "eu-central-1" {
  provider = aws.eu-central-1

  tags = var.default_vpc_component_tags.default_vpc
}

resource "aws_default_route_table" "eu-central-1" {
  provider = aws.eu-central-1

  default_route_table_id = aws_default_vpc.eu-central-1.default_route_table_id
  route                  = []
  tags                   = var.default_vpc_component_tags.default_route_table
}

resource "aws_default_network_acl" "eu-central-1" {
  provider = aws.eu-central-1

  default_network_acl_id = aws_default_vpc.eu-central-1.default_network_acl_id
  tags                   = var.default_vpc_component_tags.default_network_acl

  lifecycle {
    ignore_changes = [subnet_ids]
  }
}

resource "aws_default_security_group" "eu-central-1" {
  provider = aws.eu-central-1

  vpc_id = aws_default_vpc.eu-central-1.id
  tags   = var.default_vpc_component_tags.default_security_group
}

#---------------------------------------------------------------------
###

#tfsec:ignore:aws-vpc-no-default-vpc
resource "aws_default_vpc" "eu-west-1" {
  provider = aws.eu-west-1

  tags = var.default_vpc_component_tags.default_vpc
}

resource "aws_default_route_table" "eu-west-1" {
  provider = aws.eu-west-1

  default_route_table_id = aws_default_vpc.eu-west-1.default_route_table_id
  route                  = []
  tags                   = var.default_vpc_component_tags.default_route_table
}

resource "aws_default_network_acl" "eu-west-1" {
  provider = aws.eu-west-1

  default_network_acl_id = aws_default_vpc.eu-west-1.default_network_acl_id
  tags                   = var.default_vpc_component_tags.default_network_acl

  lifecycle {
    ignore_changes = [subnet_ids]
  }
}

resource "aws_default_security_group" "eu-west-1" {
  provider = aws.eu-west-1

  vpc_id = aws_default_vpc.eu-west-1.id
  tags   = var.default_vpc_component_tags.default_security_group
}

#---------------------------------------------------------------------
###

#tfsec:ignore:aws-vpc-no-default-vpc
resource "aws_default_vpc" "eu-west-2" {
  provider = aws.eu-west-2

  tags = var.default_vpc_component_tags.default_vpc
}

resource "aws_default_route_table" "eu-west-2" {
  provider = aws.eu-west-2

  default_route_table_id = aws_default_vpc.eu-west-2.default_route_table_id
  route                  = []
  tags                   = var.default_vpc_component_tags.default_route_table
}

resource "aws_default_network_acl" "eu-west-2" {
  provider = aws.eu-west-2

  default_network_acl_id = aws_default_vpc.eu-west-2.default_network_acl_id
  tags                   = var.default_vpc_component_tags.default_network_acl

  lifecycle {
    ignore_changes = [subnet_ids]
  }
}

resource "aws_default_security_group" "eu-west-2" {
  provider = aws.eu-west-2

  vpc_id = aws_default_vpc.eu-west-2.id
  tags   = var.default_vpc_component_tags.default_security_group
}

#---------------------------------------------------------------------
###

#tfsec:ignore:aws-vpc-no-default-vpc
resource "aws_default_vpc" "eu-west-3" {
  provider = aws.eu-west-3

  tags = var.default_vpc_component_tags.default_vpc
}

resource "aws_default_route_table" "eu-west-3" {
  provider = aws.eu-west-3

  default_route_table_id = aws_default_vpc.eu-west-3.default_route_table_id
  route                  = []
  tags                   = var.default_vpc_component_tags.default_route_table
}

resource "aws_default_network_acl" "eu-west-3" {
  provider = aws.eu-west-3

  default_network_acl_id = aws_default_vpc.eu-west-3.default_network_acl_id
  tags                   = var.default_vpc_component_tags.default_network_acl

  lifecycle {
    ignore_changes = [subnet_ids]
  }
}

resource "aws_default_security_group" "eu-west-3" {
  provider = aws.eu-west-3

  vpc_id = aws_default_vpc.eu-west-3.id
  tags   = var.default_vpc_component_tags.default_security_group
}

#---------------------------------------------------------------------
###

#tfsec:ignore:aws-vpc-no-default-vpc
resource "aws_default_vpc" "sa-east-1" {
  provider = aws.sa-east-1

  tags = var.default_vpc_component_tags.default_vpc
}

resource "aws_default_route_table" "sa-east-1" {
  provider = aws.sa-east-1

  default_route_table_id = aws_default_vpc.sa-east-1.default_route_table_id
  route                  = []
  tags                   = var.default_vpc_component_tags.default_route_table
}

resource "aws_default_network_acl" "sa-east-1" {
  provider = aws.sa-east-1

  default_network_acl_id = aws_default_vpc.sa-east-1.default_network_acl_id
  tags                   = var.default_vpc_component_tags.default_network_acl

  lifecycle {
    ignore_changes = [subnet_ids]
  }
}

resource "aws_default_security_group" "sa-east-1" {
  provider = aws.sa-east-1

  vpc_id = aws_default_vpc.sa-east-1.id
  tags   = var.default_vpc_component_tags.default_security_group
}

#---------------------------------------------------------------------
###

#tfsec:ignore:aws-vpc-no-default-vpc
resource "aws_default_vpc" "us-east-1" {
  provider = aws.us-east-1

  tags = var.default_vpc_component_tags.default_vpc
}

resource "aws_default_route_table" "us-east-1" {
  provider = aws.us-east-1

  default_route_table_id = aws_default_vpc.us-east-1.default_route_table_id
  route                  = []
  tags                   = var.default_vpc_component_tags.default_route_table
}

resource "aws_default_network_acl" "us-east-1" {
  provider = aws.us-east-1

  default_network_acl_id = aws_default_vpc.us-east-1.default_network_acl_id
  tags                   = var.default_vpc_component_tags.default_network_acl

  lifecycle {
    ignore_changes = [subnet_ids]
  }
}

resource "aws_default_security_group" "us-east-1" {
  provider = aws.us-east-1

  vpc_id = aws_default_vpc.us-east-1.id
  tags   = var.default_vpc_component_tags.default_security_group
}

#---------------------------------------------------------------------
###

#tfsec:ignore:aws-vpc-no-default-vpc
resource "aws_default_vpc" "us-west-1" {
  provider = aws.us-west-1

  tags = var.default_vpc_component_tags.default_vpc
}

resource "aws_default_route_table" "us-west-1" {
  provider = aws.us-west-1

  default_route_table_id = aws_default_vpc.us-west-1.default_route_table_id
  route                  = []
  tags                   = var.default_vpc_component_tags.default_route_table
}

resource "aws_default_network_acl" "us-west-1" {
  provider = aws.us-west-1

  default_network_acl_id = aws_default_vpc.us-west-1.default_network_acl_id
  tags                   = var.default_vpc_component_tags.default_network_acl

  lifecycle {
    ignore_changes = [subnet_ids]
  }
}

resource "aws_default_security_group" "us-west-1" {
  provider = aws.us-west-1

  vpc_id = aws_default_vpc.us-west-1.id
  tags   = var.default_vpc_component_tags.default_security_group
}

#---------------------------------------------------------------------
###

#tfsec:ignore:aws-vpc-no-default-vpc
resource "aws_default_vpc" "us-west-2" {
  provider = aws.us-west-2

  tags = var.default_vpc_component_tags.default_vpc
}

resource "aws_default_route_table" "us-west-2" {
  provider = aws.us-west-2

  default_route_table_id = aws_default_vpc.us-west-2.default_route_table_id
  route                  = []
  tags                   = var.default_vpc_component_tags.default_route_table
}

resource "aws_default_network_acl" "us-west-2" {
  provider = aws.us-west-2

  default_network_acl_id = aws_default_vpc.us-west-2.default_network_acl_id
  tags                   = var.default_vpc_component_tags.default_network_acl

  lifecycle {
    ignore_changes = [subnet_ids]
  }
}

resource "aws_default_security_group" "us-west-2" {
  provider = aws.us-west-2

  vpc_id = aws_default_vpc.us-west-2.id
  tags   = var.default_vpc_component_tags.default_security_group
}

######################################################################
