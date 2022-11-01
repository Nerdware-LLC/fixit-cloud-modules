######################################################################
### OUTPUTS

output "Distribution" {
  description = "The CloudFront distribution resource object."
  value       = aws_cloudfront_distribution.this
}

output "OriginAccessControls" {
  description = "Map of origin domain names to OAC resource objects."
  value       = aws_cloudfront_origin_access_control.map
}

output "Cache_Policies" {
  description = "Map of cache policy resource objects."
  value       = aws_cloudfront_cache_policy.map
}

output "Origin_Request_Policies" {
  description = "Map of origin request policy resource objects."
  value       = aws_cloudfront_origin_request_policy.map
}

output "Reponse_Headers_Policies" {
  description = "Map of response-headers policy resource objects."
  value       = aws_cloudfront_response_headers_policy.map
}

output "CloudFront_Functions" {
  description = "Map of CloudFront Function resource objects."
  value       = aws_cloudfront_function.map
}

output "Trusted_Key_Groups" {
  description = "Map of trusted key group resource objects."
  value       = aws_cloudfront_key_group.map
}

output "Public_Keys" {
  description = "Map of public key resource objects."
  value       = aws_cloudfront_public_key.map
}

output "Realtime_Log_Configs" {
  description = "Map of target-origin IDs to realtime log config resource objects."
  value       = aws_cloudfront_realtime_log_config.map
}

######################################################################
