######################################################################
### INPUT VARIABLES

variable "account_params" {
  type = object({
    id                     = string
    log_archive_account_id = string
    security_account_id    = string
  })
}

variable "org_cloudtrail" {
  type = object({
    name = string
    tags = optional(map(string))
  })
}

variable "org_cloudtrail_s3_bucket" {
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
  type = object({
    cloudwatch_log_group = object({
      name              = string
      retention_in_days = optional(number)
      tags              = optional(map(string))
    })
    iam_service_role = object({
      name = string
      tags = optional(map(string))
    })
    iam_role_policy = object({
      name = string
      tags = optional(map(string))
    })
  })
}

######################################################################
