######################################################################
### OUTPUTS

# Account Config Outputs:

output "Account_Password_Policy" {
  description = "The account's password-policy resource object."
  value       = aws_iam_account_password_policy.Account_PW_Policy
}

output "Global_Default_EBS_Encryption" {
  description = "Resource that ensures all EBS volumes are encrypted by default."
  value       = aws_ebs_encryption_by_default.Global_EBS_Encyption
}

#---------------------------------------------------------------------
### Access Analyzer Output:

output "Org_Access_Analyzer" {
  description = <<-EOF
  The Organization's Access Analyzer resource object.
  (will be 'null' for non-root accounts).
  EOF
  value       = one(aws_accessanalyzer_analyzer.this)
}

#---------------------------------------------------------------------
### Default VPC Component Outputs:

/* NOTE RE DEFAULT VPC COMPONENTS:
    VPC         - Each account gets 1 default VPC, with 3 default subnets. If the
                  default VPC is deleted, it cannot be re-created.
    Subnets     - Default subnets cannot be created in non-default VPCs. These
                  must be deleted manually.
    Sec Grp     - Can't be deleted.
    Route Table - "Main" route table can't be deleted.
    Net ACL     - Can't be deleted.
*/

output "Default_VPC" {
  description = "The account's default VPC resource."
  value       = aws_default_vpc.this
}

output "Default_RouteTable" {
  description = "The default VPC's default route table."
  value       = aws_default_route_table.this
}

output "Default_SecurityGroup" {
  description = "The default VPC's default security group."
  value       = aws_default_security_group.this
}

#---------------------------------------------------------------------
### CloudTrail Outputs:

output "Org_CloudTrail" {
  description = "The Organization CloudTrail (will be 'null' for non-root accounts)."
  value       = one(aws_cloudtrail.Org_CloudTrail)
}

output "Org_CloudTrail_KMS_Key" {
  description = "The Org CloudTrail KMS key (will be 'null' for non-root accounts)."
  value       = one(aws_kms_key.Org_CloudTrail_KMS_Key)
}

output "Org_CloudTrail_S3_Bucket" {
  description = <<-EOF
  The S3 bucket resource used to store logs from the Organization CloudTrail
  (will be 'null' for all accounts except Log-Archive).
  EOF
  value = (length(aws_s3_bucket.Org_CloudTrail_S3_Buckets) > 0
    ? aws_s3_bucket.Org_CloudTrail_S3_Buckets[1]
    : null
  )
}

output "Org_CloudTrail_S3_Access_Logs_Bucket" {
  description = <<-EOF
  The S3 bucket resource used to store access logs for the Org_CloudTrail S3 bucket
  (will be 'null' for all accounts except Log-Archive).
  EOF
  value = (length(aws_s3_bucket.Org_CloudTrail_S3_Buckets) > 0
    ? aws_s3_bucket.Org_CloudTrail_S3_Buckets[0]
    : null
  )
}

output "CloudWatch_LogGroup" {
  description = <<-EOF
  The CloudWatch Logs log group resource which receives an event stream from the
  Organization's CloudTrail (will be 'null' for non-root accounts).
  EOF
  value       = one(aws_cloudwatch_log_group.CloudTrail_Events)
}

output "CloudTrail-CloudWatch-Delivery_Role" {
  description = <<-EOF
  The IAM Service Role that permits delivery of Organization CloudTrail events
  to the CloudWatch_LogGroup (will be 'null' for non-root accounts).
  EOF
  value       = one(aws_iam_role.CloudWatch-Delivery_Role)
}

output "CloudTrail-CloudWatch-Delivery_Policy" {
  description = <<-EOF
  The IAM policy for "CloudTrail-CloudWatch-Delivery_Role" that permits delivery of
  Org CloudTrail events to the CW LogGroup (will be 'null' for non-root accounts).
  EOF
  value       = one(aws_iam_role_policy.CloudTrail-CloudWatch-Delivery_Policy)
}

######################################################################
