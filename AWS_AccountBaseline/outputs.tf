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
### CloudTrail Outputs

output "CloudWatch_LogGroup" {
  description = <<-EOF
  The CloudWatch Logs log group resource which receives an event stream from the
  Organization's CloudTrail (will be "null" for all accounts except Log-Archive).
  EOF
  value       = one(aws_cloudwatch_log_group.CloudTrail_Events)
}

output "CloudWatch-Delivery_Role" {
  description = <<-EOF
  The IAM Service Role that permits delivery of Organization CloudTrail events
  to the CloudWatch_LogGroup (will be "null" for all accounts except Log-Archive).
  EOF
  value       = one(aws_iam_role.CloudWatch-Delivery_Role)
}

output "CloudWatch-Delivery_Role_Policy" {
  description = <<-EOF
  The IAM policy for "CloudWatch-Delivery_Role" that permits delivery of the Organization's
  CloudTrail events to the CloudWatch Logs log group (will be "null" for all accounts except Log-Archive).
  EOF
  value       = one(aws_iam_policy.CloudWatch-Delivery_Role_Policy)
}

#---------------------------------------------------------------------
### CloudWatch Alarms Outputs

output "CloudWatch_Metric_Alarms" {
  description = "A map of CloudWatch Metric Alarm resources."
  value       = aws_cloudwatch_metric_alarm.map
}

output "CloudWatch_Metric_Filters" {
  description = "A map of CloudWatch Metric Filter resources."
  value       = aws_cloudwatch_log_metric_filter.map
}

output "CloudWatch_CIS_Alarms_SNS_Topic" {
  description = "The SNS Topic associated with the CloudWatch Metric Alarms defined in CIS Benchmarks."
  value       = one(aws_sns_topic.CloudWatch_CIS_Alarms)
}

output "CloudWatch_CIS_Alarms_SNS_Topic_Policy" {
  description = "The SNS Topic Policy associated with the CloudWatch Metric Alarms defined in CIS Benchmarks."
  value       = one(aws_sns_topic_policy.CloudWatch_CIS_Alarms)
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
