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
