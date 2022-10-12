######################################################################
### OUTPUTS

output "HostedZones" {
  description = "Map of Route53 hosted zone resource objects."
  value       = aws_route53_zone.map
}

output "Records" {
  description = "Map of Route53 record resource objects."
  value       = aws_route53_record.map
}

output "DelegationSets" {
  description = "Map of Route53 delegation set resource objects."
  value       = aws_route53_delegation_set.map
}

######################################################################
