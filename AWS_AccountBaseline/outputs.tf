######################################################################
### OUTPUTS

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
