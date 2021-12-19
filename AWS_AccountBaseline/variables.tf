######################################################################
### INPUT VARIABLES

# Org/Account Variables:

variable "account_email" {
  description = "The main email address associated with the account."
  type        = string
}

variable "log_archive_account_id" {
  description = <<-EOF
  The ID of the account that will own the log archive S3 used to store
  logs from Org-wide services like CloudTrail, CloudWatch Logs, and
  AWS-Config. This is also the account in which CloudWatch metrics
  are aggregated for Org-wide monitoring.
  EOF
  type        = string
}

variable "security_account_id" {
  description = <<-EOF
  The ID of the account that will be designated as the admin account
  for security-related services like GuardDuty and Security Hub.
  EOF
  type        = string
}

#---------------------------------------------------------------------
### Log Archive Variables:

variable "org_log_archive_s3_bucket" {
  description = "Configs for the S3 bucket used as the Organization's log archive."
  type = object({
    name = string
    tags = optional(map(string))
    access_logs_s3 = object({
      name = string
      tags = optional(map(string))
    })
  })
}

#---------------------------------------------------------------------
### Organization Services KMS Key Variables:

variable "org_kms_key" {
  description = <<-EOF
  Config object for the KMS key used to encrypt Log-Archive files, as well as
  data streams from CloudTrail, CloudWatch, SNS, etc.
  EOF
  type = object({
    alias_name    = string
    description   = optional(string)
    key_policy_id = optional(string)
    tags          = optional(map(string))
  })
}

#---------------------------------------------------------------------
### Access Analyzer Variables:

variable "org_access_analyzer" {
  description = "Config object for the Organization's Access Analyzer."
  type = object({
    name = string
    tags = optional(map(string))
  })
}

#---------------------------------------------------------------------
### Default VPC Component Variables:

variable "default_vpc_component_tags" {
  description = <<-EOF
  In accordance with best practices, this module locks down the default VPC and all
  its components to ensure all ingress/egress traffic only uses infrastructure with
  purposefully-designed rules and configs. Default subnets must be deleted manually
  - they cannot be removed via Terraform. This variable allows you to customize the
  tags on these "default" network components; defaults will be used if not provided.
  EOF
  type = object({
    default_vpc            = optional(map(string))
    default_route_table    = optional(map(string))
    default_network_acl    = optional(map(string))
    default_security_group = optional(map(string))
  })
  default = {
    default_vpc            = null
    default_route_table    = null
    default_network_acl    = null
    default_security_group = null
  }
}

#---------------------------------------------------------------------
### CloudTrail Variables:

variable "org_cloudtrail" {
  description = <<-EOF
  Config object for the Organization CloudTrail. The "cloudwatch_config"
  object is used to configure the CloudWatch Logs log group and its
  associated IAM service role which receives logs from the Org's CloudTrail.
  EOF
  type = object({
    name = string
    tags = optional(map(string))
    cloudwatch_config = object({
      log_group = object({
        name              = string
        retention_in_days = optional(number)
        tags              = optional(map(string))
      })
      iam_service_role = object({
        name        = string
        policy_name = optional(string)
        tags        = optional(map(string))
      })
    })
  })
}

#---------------------------------------------------------------------
### AWS Config Variables:

variable "org_aws_config" {
  description = <<-EOF
  Config object for the Organization's AWS-Config service. Allowed values
  for "delivery_channel.snapshot_frequency" are "One_Hour", "Three_Hours",
  "Six_Hours", "Twelve_Hours", or "TwentyFour_Hours" (default).
  EOF
  type = object({
    recorder_name = string
    aggregator = object({
      name = string
      tags = optional(map(string))
    })
    service_role = object({
      name        = string
      policy_name = string
      tags        = optional(map(string))
    })
    sns_topic = object({
      name         = string
      display_name = optional(string)
      tags         = optional(map(string))
    })
    delivery_channel = object({
      name               = string
      snapshot_frequency = optional(string)
      s3_bucket = object({
        name       = string
        key_prefix = optional(string)
      })
    })
  })
}

#---------------------------------------------------------------------
### GuardDuty Variables:

variable "guard_duty_detector" {
  description = <<-EOF
  Config object for the Organization's GuardDuty service. Allowed values
  for "finding_publishing_frequency" are "FIFTEEN_MINUTES", "ONE_HOUR",
  or "SIX_HOURS" (default).
  EOF
  type = object({
    finding_publishing_frequency = optional(string)
    tags                         = optional(map(string))
  })
  default = {
    finding_publishing_frequency = "SIX_HOURS"
    tags                         = null
  }
}

#---------------------------------------------------------------------
### CloudWatch Alarm Variables:

variable "cloudwatch_alarms" {
  description = "Config object for CIS-Benchmark CloudWatch Alarms."
  type = object({
    namespace = string
    sns_topic = object({
      name         = string
      display_name = optional(string)
      tags         = optional(map(string))
    })
  })
}

######################################################################
