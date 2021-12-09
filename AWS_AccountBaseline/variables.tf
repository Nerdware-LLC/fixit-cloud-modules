######################################################################
### INPUT VARIABLES

variable "account_params" {
  description = <<-EOF
  An object containing the IDs of accounts with important responsibilities
  within the Organization that own unique/Organization-wide resources.
  EOF
  type = object({
    log_archive_account_id = string
    security_account_id    = string
  })
}

variable "org_cloudtrail" {
  description = "Config object for the Organization CloudTrail."
  type = object({
    name = string
    tags = optional(map(string))
  })
}

variable "org_cloudtrail_s3_bucket" {
  description = "Configs for the S3 bucket used to store logs from the Org CloudTrail."
  type = object({
    name = string
    tags = optional(map(string))
    access_logs_s3 = object({
      name = string
      tags = optional(map(string))
    })
  })
}

variable "cloudtrail-to-cloudwatch-config" {
  description = <<-EOF
  Object used to configure the CloudWatch Logs log group and associated IAM
  role that receive logs from the Organization CloudTrail.
  EOF
  type = object({
    cloudwatch_log_group = object({
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
}

######################################################################
