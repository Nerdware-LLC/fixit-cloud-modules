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

variable "all_account_ids" {
  description = <<-EOF
  A list of IDs for every account within the Organization. These
  account IDs will be used in "aws:SourceAccount" Condition keys
  in IAM policy statements with an AWS Service Principal. For
  statements with AWS/IAM Principals, the "aws:PrincipalOrgID"
  Condition key will be used instead, but this key is N/A for
  actions initiated by Service Principals.
  EOF
  type        = list(string)
}

variable "s3_public_access_blocks" {
  description = <<-EOF
  Config object for account-level rules regarding S3 public access.
  By default, all S3 buckets/objects should be strictly PRIVATE. Only
  provide this variable with an override set to "false" if you know
  what you're doing and it's absolutely necessary.
  EOF
  type = object({
    block_public_acls       = optional(bool)
    block_public_policy     = optional(bool)
    ignore_public_acls      = optional(bool)
    restrict_public_buckets = optional(bool)
  })
  default = {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
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
### AWS Config Variables:

variable "config_recorder_name" {
  description = "The name to assign to the AWS-Config Recorder in each region."
  type        = string
  default     = "Org_Config_Recorder"
}

variable "config_aggregator" {
  description = <<-EOF
  Config object for the AWS-Config Aggregator resource and its associated IAM
  service role, the lone policy for which is "AWSConfigRoleForOrganizations",
  an AWS-managed policy.
  EOF
  type = object({
    name = string
    tags = optional(map(string))
    iam_service_role = object({
      name        = string
      description = optional(string)
      tags        = optional(map(string))
    })
  })
}

variable "config_iam_service_role" {
  description = <<-EOF
  Config object for IAM Service Role resource which allows the AWS-Config
  service to write findings/logs to the Organization's log-archive S3,
  use the Org's KMS key, and publish to the Config SNS Topic.
  EOF
  type = object({
    name        = string
    description = optional(string)
    tags        = optional(map(string))
    policy = object({
      name        = string
      description = optional(string)
      path        = optional(string)
      tags        = optional(map(string))
    })
  })
}

variable "config_sns_topic" {
  description = "Config object for the AWS-Config SNS Topic resource."
  type = object({
    name         = string
    display_name = optional(string)
    tags         = optional(map(string))
  })
}

variable "config_delivery_channel" {
  description = <<-EOF
  Config object for AWS-Config Delivery Channel resource. Allowed values
  for "snapshot_frequency" are "One_Hour", "Three_Hours", "Six_Hours",
  "Twelve_Hours", or "TwentyFour_Hours" (default).
  EOF
  type = object({
    name               = string
    snapshot_frequency = optional(string)
    s3_bucket = object({
      name       = string
      key_prefix = optional(string)
    })
  })
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
### Log Archive Variables:

variable "org_log_archive_s3_bucket" {
  description = <<-EOF
  Config object for the Log-Archive account's titular S3 bucket used as
  the Organization's log archive.
  EOF
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
### CloudTrail Variables:

variable "org_cloudtrail" {
  description = "Config object for the Organization CloudTrail in the root account."
  type = object({
    name = string
    tags = optional(map(string))
  })
}

variable "org_cloudtrail_cloudwatch_logs_group" {
  description = <<-EOF
  Config object for the CloudWatch Logs log group and associated
  IAM service role used by the Log-Archive account to receive
  logs from the Organization's CloudTrail.
  EOF
  type = object({
    log_group = object({
      name              = string
      retention_in_days = optional(number)
      tags              = optional(map(string))
    })
    iam_service_role = object({
      name = string
      tags = optional(map(string))
      policy = object({
        name        = string
        description = optional(string)
        path        = optional(string)
        tags        = optional(map(string))
      })
    })
  })
}

#---------------------------------------------------------------------
### Organization Services KMS Key Variables:

variable "org_kms_key" {
  description = <<-EOF
  Config object for the KMS key used to encrypt Log-Archive files, as well as
  data streams from CloudTrail, CloudWatch, SNS, etc. The "replica_key_tags"
  property will be added to the "tags" field of all replica keys.
  EOF
  type = object({
    alias_name       = string
    description      = optional(string)
    key_policy_id    = optional(string)
    tags             = optional(map(string))
    replica_key_tags = optional(map(string))
  })
}

######################################################################
