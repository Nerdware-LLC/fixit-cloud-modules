######################################################################
### INPUT VARIABLES
######################################################################
### Account Settings Variables:

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
  Config object for the CloudWatch Logs log group and its associated IAM
  service role used to receive logs from the Organization's CloudTrail.
  EOF
  type = object({
    name                           = string
    retention_in_days              = optional(number)
    tags                           = optional(map(string))
    logs_delivery_service_role_arn = string
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

######################################################################
