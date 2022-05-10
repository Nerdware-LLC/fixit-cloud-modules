######################################################################
### OUTPUTS
######################################################################
### S3 Bucket

output "S3_Bucket" {
  description = "The S3 bucket resource."
  value       = aws_s3_bucket.this
}

#---------------------------------------------------------------------
### S3 Bucket Versioning

output "S3_Bucket_Versioning_Config" {
  description = "The S3 bucket versioning config resource."
  value       = aws_s3_bucket_versioning.this
}

#---------------------------------------------------------------------
### S3 Bucket SSE

output "S3_Bucket_SSE_Config" {
  description = "The S3 bucket SSE config resource."
  value       = aws_s3_bucket_server_side_encryption_configuration.this
}

#---------------------------------------------------------------------
### S3 Object Lock - Bucket Default Retention

output "S3_Bucket_Object_Lock_Default_Retention_Config" {
  description = "The S3 bucket's object-lock default retention config resource."
  value       = one(aws_s3_bucket_object_lock_configuration.list)
}

#---------------------------------------------------------------------
### S3 Bucket Logging

output "S3_Bucket_Logging_Config" {
  description = "The S3 bucket access logging config resource."
  value       = one(aws_s3_bucket_logging.list)
}

#---------------------------------------------------------------------
### S3 Bucket Transfer Acceleration

output "S3_Bucket_Transfer_Acceleration_Config" {
  description = "The S3 bucket transfer acceleration config resource."
  value       = one(aws_s3_bucket_accelerate_configuration.list)
}

#---------------------------------------------------------------------
### Object Ownership - Enforce Bucket Owner

output "S3_Buket_Ownership_Controls" {
  description = "The S3 bucket ownership controls config resource."
  value       = aws_s3_bucket_ownership_controls.this
}

#---------------------------------------------------------------------
### S3 Bucket Policy

output "S3_Bucket_Policy" {
  description = "The S3 bucket policy resource."
  value       = aws_s3_bucket_policy.this
}

#---------------------------------------------------------------------
### S3 Bucket Public Access Blocks

output "S3_Bucket_Public_Access_Block" {
  description = "The S3 bucket public access block config resource."
  value       = aws_s3_bucket_public_access_block.this
}

#---------------------------------------------------------------------
## S3 Bucket Lifecycle Config

output "S3_Bucket_Lifecycle_Config" {
  description = "Map of S3 bucket lifecycle rule config resources."
  value       = one(aws_s3_bucket_lifecycle_configuration.list)
}

#---------------------------------------------------------------------
### S3 Bucket Replication Config

output "S3_Bucket_Replication_Config" {
  description = "The S3 bucket replication config resource."
  value       = one(aws_s3_bucket_replication_configuration.list)
}

#---------------------------------------------------------------------
### S3 Web Host

output "S3_Bucket_Web_Host_Config" {
  description = "The S3 bucket web host config resource."
  value       = one(aws_s3_bucket_website_configuration.list)
}

#---------------------------------------------------------------------
### S3 CORS Config

output "S3_Bucket_CORS_Config" {
  description = "The S3 bucket CORS config resource."
  value       = one(aws_s3_bucket_cors_configuration.list)
}

######################################################################
