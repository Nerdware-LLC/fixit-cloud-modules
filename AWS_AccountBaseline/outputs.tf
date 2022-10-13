######################################################################
### OUTPUTS
######################################################################
### Account Config Outputs

output "Account_Password_Policy" {
  description = "The account's password-policy resource object."
  value       = aws_iam_account_password_policy.this
}

output "Global_Default_EBS_Encryption" {
  description = "Resource that ensures all EBS volumes are encrypted by default."
  value       = aws_ebs_encryption_by_default.this
}

output "Account-Level_S3_Public_Access_Block" {
  description = "Account-level S3 public access block resource."
  value       = aws_s3_account_public_access_block.this
}

#---------------------------------------------------------------------
### Default VPC Component Outputs

output "Default_VPC_Components_By_Region" {
  description = <<-EOF
  A map of default VPC resources by region. Included in each region is the
  default VPC, default NACL, default route table, and default security group.
  EOF

  value = {
    "ap-northeast-1" = {
      aws_default_vpc            = aws_default_vpc.ap-northeast-1
      aws_default_route_table    = aws_default_route_table.ap-northeast-1
      aws_default_network_acl    = aws_default_network_acl.ap-northeast-1
      aws_default_security_group = aws_default_security_group.ap-northeast-1
    }
    "ap-northeast-2" = {
      aws_default_vpc            = aws_default_vpc.ap-northeast-2
      aws_default_route_table    = aws_default_route_table.ap-northeast-2
      aws_default_network_acl    = aws_default_network_acl.ap-northeast-2
      aws_default_security_group = aws_default_security_group.ap-northeast-2
    }
    "ap-northeast-3" = {
      aws_default_vpc            = aws_default_vpc.ap-northeast-3
      aws_default_route_table    = aws_default_route_table.ap-northeast-3
      aws_default_network_acl    = aws_default_network_acl.ap-northeast-3
      aws_default_security_group = aws_default_security_group.ap-northeast-3
    }
    "ap-south-1" = {
      aws_default_vpc            = aws_default_vpc.ap-south-1
      aws_default_route_table    = aws_default_route_table.ap-south-1
      aws_default_network_acl    = aws_default_network_acl.ap-south-1
      aws_default_security_group = aws_default_security_group.ap-south-1
    }
    "ap-southeast-1" = {
      aws_default_vpc            = aws_default_vpc.ap-southeast-1
      aws_default_route_table    = aws_default_route_table.ap-southeast-1
      aws_default_network_acl    = aws_default_network_acl.ap-southeast-1
      aws_default_security_group = aws_default_security_group.ap-southeast-1
    }
    "ap-southeast-2" = {
      aws_default_vpc            = aws_default_vpc.ap-southeast-2
      aws_default_route_table    = aws_default_route_table.ap-southeast-2
      aws_default_network_acl    = aws_default_network_acl.ap-southeast-2
      aws_default_security_group = aws_default_security_group.ap-southeast-2
    }
    "ca-central-1" = {
      aws_default_vpc            = aws_default_vpc.ca-central-1
      aws_default_route_table    = aws_default_route_table.ca-central-1
      aws_default_network_acl    = aws_default_network_acl.ca-central-1
      aws_default_security_group = aws_default_security_group.ca-central-1
    }
    "eu-north-1" = {
      aws_default_vpc            = aws_default_vpc.eu-north-1
      aws_default_route_table    = aws_default_route_table.eu-north-1
      aws_default_network_acl    = aws_default_network_acl.eu-north-1
      aws_default_security_group = aws_default_security_group.eu-north-1
    }
    "eu-central-1" = {
      aws_default_vpc            = aws_default_vpc.eu-central-1
      aws_default_route_table    = aws_default_route_table.eu-central-1
      aws_default_network_acl    = aws_default_network_acl.eu-central-1
      aws_default_security_group = aws_default_security_group.eu-central-1
    }
    "eu-west-1" = {
      aws_default_vpc            = aws_default_vpc.eu-west-1
      aws_default_route_table    = aws_default_route_table.eu-west-1
      aws_default_network_acl    = aws_default_network_acl.eu-west-1
      aws_default_security_group = aws_default_security_group.eu-west-1
    }
    "eu-west-2" = {
      aws_default_vpc            = aws_default_vpc.eu-west-2
      aws_default_route_table    = aws_default_route_table.eu-west-2
      aws_default_network_acl    = aws_default_network_acl.eu-west-2
      aws_default_security_group = aws_default_security_group.eu-west-2
    }
    "eu-west-3" = {
      aws_default_vpc            = aws_default_vpc.eu-west-3
      aws_default_route_table    = aws_default_route_table.eu-west-3
      aws_default_network_acl    = aws_default_network_acl.eu-west-3
      aws_default_security_group = aws_default_security_group.eu-west-3
    }
    "sa-east-1" = {
      aws_default_vpc            = aws_default_vpc.sa-east-1
      aws_default_route_table    = aws_default_route_table.sa-east-1
      aws_default_network_acl    = aws_default_network_acl.sa-east-1
      aws_default_security_group = aws_default_security_group.sa-east-1
    }
    "us-east-1" = {
      aws_default_vpc            = aws_default_vpc.us-east-1
      aws_default_route_table    = aws_default_route_table.us-east-1
      aws_default_network_acl    = aws_default_network_acl.us-east-1
      aws_default_security_group = aws_default_security_group.us-east-1
    }
    "us-east-2" = {
      aws_default_vpc            = aws_default_vpc.us-east-2
      aws_default_route_table    = aws_default_route_table.us-east-2
      aws_default_network_acl    = aws_default_network_acl.us-east-2
      aws_default_security_group = aws_default_security_group.us-east-2
    }
    "us-west-1" = {
      aws_default_vpc            = aws_default_vpc.us-west-1
      aws_default_route_table    = aws_default_route_table.us-west-1
      aws_default_network_acl    = aws_default_network_acl.us-west-1
      aws_default_security_group = aws_default_security_group.us-west-1
    }
    "us-west-2" = {
      aws_default_vpc            = aws_default_vpc.us-west-2
      aws_default_route_table    = aws_default_route_table.us-west-2
      aws_default_network_acl    = aws_default_network_acl.us-west-2
      aws_default_security_group = aws_default_security_group.us-west-2
    }
  }
}

######################################################################
