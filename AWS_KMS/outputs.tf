######################################################################
### OUTPUTS

output "KMS_Key" {
  description = "The KMS Key resource object."
  value       = aws_kms_key.this
}

output "KMS_Key_Alias" {
  description = "The KMS Key Alias resource object."
  value       = one(aws_kms_alias.list)
}

######################################################################
