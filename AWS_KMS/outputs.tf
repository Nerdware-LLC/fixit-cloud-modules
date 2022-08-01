######################################################################
### OUTPUTS

output "KMS_Key" {
  description = "The KMS Key resource object."
  value       = aws_kms_key.this
}

output "KMS_Key_Alias" {
  description = "The KMS Key Alias resource object."
  value       = lookup(aws_kms_alias.map, var.key_alias, null)
}

output "Regional_Replicas" {
  description = "Map of regions to KMS Key Replicas resource objects."
  value = {
    ap-northeast-1 = one(aws_kms_replica_key.ap-northeast-1) # Asia Pacific (Tokyo)
    ap-northeast-2 = one(aws_kms_replica_key.ap-northeast-2) # Asia Pacific (Seoul)
    ap-northeast-3 = one(aws_kms_replica_key.ap-northeast-3) # Asia Pacific (Osaka)
    ap-south-1     = one(aws_kms_replica_key.ap-south-1)     # Asia Pacific (Mumbai)
    ap-southeast-1 = one(aws_kms_replica_key.ap-southeast-1) # Asia Pacific (Singapore)
    ap-southeast-2 = one(aws_kms_replica_key.ap-southeast-2) # Asia Pacific (Sydney)
    ca-central-1   = one(aws_kms_replica_key.ca-central-1)   # Canada (Central)
    eu-north-1     = one(aws_kms_replica_key.eu-north-1)     # Europe (Stockholm)
    eu-central-1   = one(aws_kms_replica_key.eu-central-1)   # Europe (Frankfurt)
    eu-west-1      = one(aws_kms_replica_key.eu-west-1)      # Europe (Ireland)
    eu-west-2      = one(aws_kms_replica_key.eu-west-2)      # Europe (London)
    eu-west-3      = one(aws_kms_replica_key.eu-west-3)      # Europe (Paris)
    sa-east-1      = one(aws_kms_replica_key.sa-east-1)      # South America (São Paulo)
    us-east-1      = one(aws_kms_replica_key.us-east-1)      # US East (N. Virginia)
    us-west-1      = one(aws_kms_replica_key.us-west-1)      # US West (N. California)
    us-west-2      = one(aws_kms_replica_key.us-west-2)      # US West (Oregon)
  }
}

######################################################################
