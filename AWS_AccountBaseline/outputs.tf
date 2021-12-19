######################################################################
### OUTPUTS
#---------------------------------------------------------------------
### Access Analyzer Outputs:

output "Org_Access_Analyzer" {
  description = <<-EOF
  The Organization's Access Analyzer resource object (will be "null" for non-root
  accounts).
  EOF
  value       = one(aws_accessanalyzer_analyzer.Org_AccessAnalyzer)
}

#---------------------------------------------------------------------
### Account Config Outputs:

output "Account_Password_Policy" {
  description = "The account's password-policy resource object."
  value       = aws_iam_account_password_policy.this
}

output "Global_Default_EBS_Encryption" {
  description = "Resource that ensures all EBS volumes are encrypted by default."
  value       = aws_ebs_encryption_by_default.this
}

#---------------------------------------------------------------------
### CloudWatch Alarms Outputs:

output "CloudWatch_Metric_Alarms" {
  description = "A map of CloudWatch Metric Alarm resources."
  value       = aws_cloudwatch_metric_alarm.map
}

output "CloudWatch_Metric_Filters" {
  description = "A map of CloudWatch Metric Filter resources."
  value       = aws_cloudwatch_log_metric_filter.map
}

output "CloudWatch_Alarms_SNS_Topic" {
  description = "The SNS Topic associated with CloudWatch Metric Alarms."
  value       = one(aws_sns_topic.CloudWatch_Alarms)
}

output "CloudWatch_Alarms_SNS_Topic_Policy" {
  description = "The SNS Topic Policy associated with CloudWatch Metric Alarms."
  value       = one(aws_sns_topic_policy.CloudWatch_Alarms)
}

#---------------------------------------------------------------------
### AWS Config Outputs:

output "Org_Config_Recorder" {
  description = <<-EOF
  The Organization's AWS-Config recorder resource (will be "null" for non-root
  accounts).
  EOF
  value       = one(aws_config_configuration_recorder.Org_Config_Recorder)
}

output "Org_Config_Recorder_Status" {
  description = <<-EOF
  The Org's AWS-Config recorder's STATUS resource (will be "null" for non-root
  accounts).
  EOF
  value       = one(aws_config_configuration_recorder_status.Org_Config_Recorder_Status)
}

output "Org_Config_Aggregator" {
  description = <<-EOF
  The Org's AWS-Config recorder's aggregator resource (will be "null" for non-root
  accounts).
  EOF
  value       = one(aws_config_configuration_aggregator.Org_Config_Aggregator)
}

output "Org_Config_Role" {
  description = <<-EOF
  The IAM Service Role that permits read/write requests to/from the Config delivery
  channel resource (will be "null" for non-root accounts).
  EOF
  value       = one(aws_iam_role.Org_Config_Role)
}

output "Org_Config_Role_Policy" {
  description = <<-EOF
  The IAM policy for "Org_Config_Role" that permits read/write requests to/from the
  Config delivery channel resource (will be "null" for non-root accounts).
  EOF
  value       = one(aws_iam_role_policy.Org_Config_Role_Policy)
}

output "Org_Config_SNS_Topic" {
  description = "The Org's AWS-Config SNS Topic (will be \"null\" for non-root accounts)."
  value       = one(aws_sns_topic.Org_Config_SNS_Topic)
}

output "Org_Config_SNS_Topic_Policy" {
  description = "The Org's AWS-Config SNS Topic Policy (will be \"null\" for non-root accounts)."
  value       = one(aws_sns_topic_policy.Org_Config_SNS_Topic_Policy)
}

output "Org_Config_Delivery_Channel" {
  description = "The Org's AWS-Config Delivery Channel (will be \"null\" for non-root accounts)."
  value       = one(aws_config_delivery_channel.Org_Config_Delivery_Channel)
}

#---------------------------------------------------------------------
### Default VPC Component Outputs:

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

#---------------------------------------------------------------------
### GuardDuty Outputs:

output "GuardDuty_BY_REGION" {
  description = "A map of all GuardDuty resources, organized by region."
  value = {
    "ap-northeast-1" = {
      Org_Admin_Account = one(aws_guardduty_organization_admin_account.ap-northeast-1)
      Org_Config        = one(aws_guardduty_organization_configuration.ap-northeast-1)
      Detector          = one(aws_guardduty_detector.ap-northeast-1)
    }
    "ap-northeast-2" = {
      Org_Admin_Account = one(aws_guardduty_organization_admin_account.ap-northeast-2)
      Org_Config        = one(aws_guardduty_organization_configuration.ap-northeast-2)
      Detector          = one(aws_guardduty_detector.ap-northeast-2)
    }
    "ap-northeast-3" = {
      Org_Admin_Account = one(aws_guardduty_organization_admin_account.ap-northeast-3)
      Org_Config        = one(aws_guardduty_organization_configuration.ap-northeast-3)
      Detector          = one(aws_guardduty_detector.ap-northeast-3)
    }
    "ap-south-1" = {
      Org_Admin_Account = one(aws_guardduty_organization_admin_account.ap-south-1)
      Org_Config        = one(aws_guardduty_organization_configuration.ap-south-1)
      Detector          = one(aws_guardduty_detector.ap-south-1)
    }
    "ap-southeast-1" = {
      Org_Admin_Account = one(aws_guardduty_organization_admin_account.ap-southeast-1)
      Org_Config        = one(aws_guardduty_organization_configuration.ap-southeast-1)
      Detector          = one(aws_guardduty_detector.ap-southeast-1)
    }
    "ap-southeast-2" = {
      Org_Admin_Account = one(aws_guardduty_organization_admin_account.ap-southeast-2)
      Org_Config        = one(aws_guardduty_organization_configuration.ap-southeast-2)
      Detector          = one(aws_guardduty_detector.ap-southeast-2)
    }
    "ca-central-1" = {
      Org_Admin_Account = one(aws_guardduty_organization_admin_account.ca-central-1)
      Org_Config        = one(aws_guardduty_organization_configuration.ca-central-1)
      Detector          = one(aws_guardduty_detector.ca-central-1)
    }
    "eu-north-1" = {
      Org_Admin_Account = one(aws_guardduty_organization_admin_account.eu-north-1)
      Org_Config        = one(aws_guardduty_organization_configuration.eu-north-1)
      Detector          = one(aws_guardduty_detector.eu-north-1)
    }
    "eu-central-1" = {
      Org_Admin_Account = one(aws_guardduty_organization_admin_account.eu-central-1)
      Org_Config        = one(aws_guardduty_organization_configuration.eu-central-1)
      Detector          = one(aws_guardduty_detector.eu-central-1)
    }
    "eu-west-1" = {
      Org_Admin_Account = one(aws_guardduty_organization_admin_account.eu-west-1)
      Org_Config        = one(aws_guardduty_organization_configuration.eu-west-1)
      Detector          = one(aws_guardduty_detector.eu-west-1)
    }
    "eu-west-2" = {
      Org_Admin_Account = one(aws_guardduty_organization_admin_account.eu-west-2)
      Org_Config        = one(aws_guardduty_organization_configuration.eu-west-2)
      Detector          = one(aws_guardduty_detector.eu-west-2)
    }
    "eu-west-3" = {
      Org_Admin_Account = one(aws_guardduty_organization_admin_account.eu-west-3)
      Org_Config        = one(aws_guardduty_organization_configuration.eu-west-3)
      Detector          = one(aws_guardduty_detector.eu-west-3)
    }
    "sa-east-1" = {
      Org_Admin_Account = one(aws_guardduty_organization_admin_account.sa-east-1)
      Org_Config        = one(aws_guardduty_organization_configuration.sa-east-1)
      Detector          = one(aws_guardduty_detector.sa-east-1)
    }
    "us-east-1" = {
      Org_Admin_Account = one(aws_guardduty_organization_admin_account.us-east-1)
      Org_Config        = one(aws_guardduty_organization_configuration.us-east-1)
      Detector          = one(aws_guardduty_detector.us-east-1)
    }
    "us-east-2" = {
      Org_Admin_Account = one(aws_guardduty_organization_admin_account.us-east-2)
      Org_Config        = one(aws_guardduty_organization_configuration.us-east-2)
      Detector          = one(aws_guardduty_detector.us-east-2)
    }
    "us-west-1" = {
      Org_Admin_Account = one(aws_guardduty_organization_admin_account.us-west-1)
      Org_Config        = one(aws_guardduty_organization_configuration.us-west-1)
      Detector          = one(aws_guardduty_detector.us-west-1)
    }
    "us-west-2" = {
      Org_Admin_Account = one(aws_guardduty_organization_admin_account.us-west-2)
      Org_Config        = one(aws_guardduty_organization_configuration.us-west-2)
      Detector          = one(aws_guardduty_detector.us-west-2)
    }
  }
}

#---------------------------------------------------------------------
### Log Archive Outputs:

output "Org_Log_Archive_S3_Bucket" {
  description = <<-EOF
  The S3 bucket used to store logs from the Organization's Config and CloudTrail
  services (will be "null" for all accounts except Log-Archive).
  EOF
  value = (
    length(aws_s3_bucket.list) > 0
    ? aws_s3_bucket.list[1]
    : null
  )
}

output "Org_Log_Archive_S3_Access_Logs_Bucket" {
  description = <<-EOF
  The S3 bucket resource used to store access logs for the Organization's
  Log-Archive S3 bucket (will be "null" for all accounts except Log-Archive).
  EOF
  value = (
    length(aws_s3_bucket.list) > 0
    ? aws_s3_bucket.list[0]
    : null
  )
}

#---------------------------------------------------------------------
### CloudTrail Outputs:

output "Org_CloudTrail" {
  description = "The Organization CloudTrail (will be \"null\" for non-root accounts)."
  value       = one(aws_cloudtrail.Org_CloudTrail)
}

output "CloudWatch_LogGroup" {
  description = <<-EOF
  The CloudWatch Logs log group resource which receives an event stream from the
  Organization's CloudTrail (will be "null" for non-root accounts).
  EOF
  value       = one(aws_cloudwatch_log_group.CloudTrail_Events)
}

output "CloudWatch-Delivery_Role" {
  description = <<-EOF
  The IAM Service Role that permits delivery of Organization CloudTrail events
  to the CloudWatch_LogGroup (will be "null" for non-root accounts).
  EOF
  value       = one(aws_iam_role.CloudWatch-Delivery_Role)
}

output "CloudWatch-Delivery_Role_Policy" {
  description = <<-EOF
  The IAM policy for "CloudWatch-Delivery_Role" that permits delivery of the Organization's
  CloudTrail events to the CloudWatch Logs log group (will be "null" for non-root accounts).
  EOF
  value       = one(aws_iam_role_policy.CloudWatch-Delivery_Role_Policy)
}

#---------------------------------------------------------------------
### Organization Services KMS Key Outputs:

output "Org_Services_KMS_Key" {
  description = <<-EOF
  The KMS key resource used to encrypt Log-Archive files, as well as data streams
  related to Organization-wide services like CloudTrail and CloudWatch.
  EOF
  value       = one(aws_kms_key.Org_KMS_Key)
}

#---------------------------------------------------------------------
### SecurityHub Outputs:

output "SecurityHub_Org_Admin_Account" {
  description = "The SecurityHub Org Admin Account resource."
  value       = one(aws_securityhub_organization_admin_account.Org_Admin_Account)
}

output "SecurityHub_Org_Config" {
  description = "The SecurityHub Organization configuration resource."
  value       = one(aws_securityhub_organization_configuration.Org_Config)
}

output "SecurityHub_Member_Account" {
  description = "A SecurityHub Member Account resource."
  value       = one(aws_securityhub_member.Member_Account)
}

output "SecurityHub_Finding_Aggregator" {
  description = "The SecurityHub Finding Aggregator resource."
  value       = aws_securityhub_finding_aggregator.All_Regions
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
