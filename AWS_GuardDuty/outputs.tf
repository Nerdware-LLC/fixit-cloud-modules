######################################################################
### OUTPUTS

output "GuardDuty_Org_Admin_Account_BY_REGION" {
  description = "A map of GuardDuty Delegated Admin resources, organized by region."
  value = {
    "ap-northeast-1" = one(aws_guardduty_organization_admin_account.ap-northeast-1)
    "ap-northeast-2" = one(aws_guardduty_organization_admin_account.ap-northeast-2)
    "ap-northeast-3" = one(aws_guardduty_organization_admin_account.ap-northeast-3)
    "ap-south-1"     = one(aws_guardduty_organization_admin_account.ap-south-1)
    "ap-southeast-1" = one(aws_guardduty_organization_admin_account.ap-southeast-1)
    "ap-southeast-2" = one(aws_guardduty_organization_admin_account.ap-southeast-2)
    "ca-central-1"   = one(aws_guardduty_organization_admin_account.ca-central-1)
    "eu-north-1"     = one(aws_guardduty_organization_admin_account.eu-north-1)
    "eu-central-1"   = one(aws_guardduty_organization_admin_account.eu-central-1)
    "eu-west-1"      = one(aws_guardduty_organization_admin_account.eu-west-1)
    "eu-west-2"      = one(aws_guardduty_organization_admin_account.eu-west-2)
    "eu-west-3"      = one(aws_guardduty_organization_admin_account.eu-west-3)
    "sa-east-1"      = one(aws_guardduty_organization_admin_account.sa-east-1)
    "us-east-1"      = one(aws_guardduty_organization_admin_account.us-east-1)
    "us-east-2"      = one(aws_guardduty_organization_admin_account.us-east-2)
    "us-west-1"      = one(aws_guardduty_organization_admin_account.us-west-1)
    "us-west-2"      = one(aws_guardduty_organization_admin_account.us-west-2)
  }
}

#---------------------------------------------------------------------

output "GuardDuty_Org_Config_BY_REGION" {
  description = "A map of GuardDuty Organization Config resources, organized by region."
  value = {
    "ap-northeast-1" = one(aws_guardduty_organization_configuration.ap-northeast-1)
    "ap-northeast-2" = one(aws_guardduty_organization_configuration.ap-northeast-2)
    "ap-northeast-3" = one(aws_guardduty_organization_configuration.ap-northeast-3)
    "ap-south-1"     = one(aws_guardduty_organization_configuration.ap-south-1)
    "ap-southeast-1" = one(aws_guardduty_organization_configuration.ap-southeast-1)
    "ap-southeast-2" = one(aws_guardduty_organization_configuration.ap-southeast-2)
    "ca-central-1"   = one(aws_guardduty_organization_configuration.ca-central-1)
    "eu-north-1"     = one(aws_guardduty_organization_configuration.eu-north-1)
    "eu-central-1"   = one(aws_guardduty_organization_configuration.eu-central-1)
    "eu-west-1"      = one(aws_guardduty_organization_configuration.eu-west-1)
    "eu-west-2"      = one(aws_guardduty_organization_configuration.eu-west-2)
    "eu-west-3"      = one(aws_guardduty_organization_configuration.eu-west-3)
    "sa-east-1"      = one(aws_guardduty_organization_configuration.sa-east-1)
    "us-east-1"      = one(aws_guardduty_organization_configuration.us-east-1)
    "us-east-2"      = one(aws_guardduty_organization_configuration.us-east-2)
    "us-west-1"      = one(aws_guardduty_organization_configuration.us-west-1)
    "us-west-2"      = one(aws_guardduty_organization_configuration.us-west-2)
  }
}

#---------------------------------------------------------------------

output "GuardDuty_Detectors_BY_REGION" {
  description = "A map of GuardDuty Detector resources, organized by region."
  value = {
    "ap-northeast-1" = one(aws_guardduty_detector.ap-northeast-1)
    "ap-northeast-2" = one(aws_guardduty_detector.ap-northeast-2)
    "ap-northeast-3" = one(aws_guardduty_detector.ap-northeast-3)
    "ap-south-1"     = one(aws_guardduty_detector.ap-south-1)
    "ap-southeast-1" = one(aws_guardduty_detector.ap-southeast-1)
    "ap-southeast-2" = one(aws_guardduty_detector.ap-southeast-2)
    "ca-central-1"   = one(aws_guardduty_detector.ca-central-1)
    "eu-north-1"     = one(aws_guardduty_detector.eu-north-1)
    "eu-central-1"   = one(aws_guardduty_detector.eu-central-1)
    "eu-west-1"      = one(aws_guardduty_detector.eu-west-1)
    "eu-west-2"      = one(aws_guardduty_detector.eu-west-2)
    "eu-west-3"      = one(aws_guardduty_detector.eu-west-3)
    "sa-east-1"      = one(aws_guardduty_detector.sa-east-1)
    "us-east-1"      = one(aws_guardduty_detector.us-east-1)
    "us-east-2"      = one(aws_guardduty_detector.us-east-2)
    "us-west-1"      = one(aws_guardduty_detector.us-west-1)
    "us-west-2"      = one(aws_guardduty_detector.us-west-2)
  }
}

######################################################################
