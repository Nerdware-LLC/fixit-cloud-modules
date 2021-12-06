######################################################################
### OUTPUTS

output "Org_CloudTrail" {
  value = one(aws_cloudtrail.Org_CloudTrail)
}

output "Org_CloudTrail_KMS_Key" {
  value = one(aws_kms_key.Org_CloudTrail_KMS_Key)
}

output "Org_CloudTrail_S3_Bucket" {
  value = one(aws_s3_bucket.Org_CloudTrail_S3_Bucket)
}

output "CloudWatch_LogGroup" {
  description = <<-EOF
  The CloudWatch log group for this account which receives an event stream for
  the Organization's CloudTrail.
  EOF
  value       = one(aws_cloudwatch_log_group.CloudTrail_Events)
}

output "CloudTrail-CloudWatch-Delivery_Role" {
  description = "The IAM Service Role that delivers CloudTrail events to the CloudWatch_LogGroup."
  value       = one(aws_iam_role.CloudWatch-Delivery_Role)
}

output "CloudTrail-CloudWatch-Delivery_Policy" {
  value = one(aws_iam_role_policy.CloudTrail-CloudWatch-Delivery_Policy)
}

######################################################################
