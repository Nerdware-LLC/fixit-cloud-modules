######################################################################
### OUTPUTS

output "SecurityHub_Org_Admin_Account" {
  description = "The SecurityHub Org Admin Account resource."
  value       = one(aws_securityhub_organization_admin_account.Org_Admin_Account)
}

output "SecurityHub_Org_Config" {
  description = "The SecurityHub Organization configuration resource."
  value       = one(aws_securityhub_organization_configuration.Org_Config)
}

output "SecurityHub_Member_Account" {
  description = "A SecurityHub Member Account resource (will be \"null\" for non-Security accounts)."
  value       = local.IS_SECURITYHUB_ADMIN_ACCOUNT ? aws_securityhub_member.Member_Accounts : null
}

output "SecurityHub_Finding_Aggregator" {
  description = "The SecurityHub Finding Aggregator resource."
  value       = one(aws_securityhub_finding_aggregator.All_Regions)
}

output "SecurityHub_Subscriptions_BY_REGION" {
  description = "A map of SecurityHub Standards subscription resources, organized by region."
  value = {
    "ap-northeast-1" = aws_securityhub_standards_subscription.ap-northeast-1
    "ap-northeast-2" = aws_securityhub_standards_subscription.ap-northeast-2
    "ap-northeast-3" = aws_securityhub_standards_subscription.ap-northeast-3
    "ap-south-1"     = aws_securityhub_standards_subscription.ap-south-1
    "ap-southeast-1" = aws_securityhub_standards_subscription.ap-southeast-1
    "ap-southeast-2" = aws_securityhub_standards_subscription.ap-southeast-2
    "ca-central-1"   = aws_securityhub_standards_subscription.ca-central-1
    "eu-north-1"     = aws_securityhub_standards_subscription.eu-north-1
    "eu-central-1"   = aws_securityhub_standards_subscription.eu-central-1
    "eu-west-1"      = aws_securityhub_standards_subscription.eu-west-1
    "eu-west-2"      = aws_securityhub_standards_subscription.eu-west-2
    "eu-west-3"      = aws_securityhub_standards_subscription.eu-west-3
    "sa-east-1"      = aws_securityhub_standards_subscription.sa-east-1
    "us-east-1"      = aws_securityhub_standards_subscription.us-east-1
    "us-east-2"      = aws_securityhub_standards_subscription.us-east-2
    "us-west-1"      = aws_securityhub_standards_subscription.us-west-1
    "us-west-2"      = aws_securityhub_standards_subscription.us-west-2
  }
}

######################################################################
