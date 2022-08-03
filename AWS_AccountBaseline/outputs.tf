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

output "Default_VPC" {
  description = "The account's default VPC resource."
  value       = aws_default_vpc.this
}

output "Default_RouteTable" {
  description = "The default VPC's default route table."
  value       = aws_default_route_table.this
}

output "Default_Network_ACL" {
  description = "The default VPC's default network ACL."
  value       = aws_default_network_acl.this
}

output "Default_SecurityGroup" {
  description = "The default VPC's default security group."
  value       = aws_default_security_group.this
}

######################################################################
