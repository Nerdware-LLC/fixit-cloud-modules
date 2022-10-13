######################################################################
### INPUT VARIABLES
######################################################################
### Account Settings Inputs

variable "iam_account_password_policy" {
  description = <<-EOF
  (Optional) Config object for customizing an account's IAM password policy.
  If not provided, by default this module will set each value to the minimum
  required by CIS AWS Foundations Benchmark (v1.4.0). For "max_password_age",
  this value is 90 days, "min_password_length" is 14, and the number of times
  a password can be reused - "password_reuse_prevention" - is 24. Values which
  are below those required by the CIS Benchmark Controls will result in a
  validation error.
  EOF

  type = object({
    max_password_age          = optional(number, 90)
    min_password_length       = optional(number, 14)
    password_reuse_prevention = optional(number, 24)
  })

  default = {
    max_password_age          = 90
    min_password_length       = 14
    password_reuse_prevention = 24
  }

  validation {
    condition = alltrue([
      coalesce(var.iam_account_password_policy.max_password_age, 90) >= 90,
      coalesce(var.iam_account_password_policy.min_password_length, 14) >= 14,
      coalesce(var.iam_account_password_policy.password_reuse_prevention, 24) >= 24
    ])
    error_message = "All values must be equal to or greater than the minimum required by CIS AWS Foundations Benchmark (v1.4)."
  }
}

#---------------------------------------------------------------------
### Default VPC Component Inputs

variable "default_vpc_component_tags" {
  description = <<-EOF
  (Optional) Map of default resource types to tags for each respective type.
  Any provided tags are applied to default resources of that type in all regions.

  In accordance with best practices, this module locks down the default VPC and all
  its components to ensure all ingress/egress traffic only uses infrastructure with
  purposefully-designed rules and configs. Default subnets must be deleted manually
  - they cannot be removed via Terraform. This variable allows you to customize the
  tags on these default network components.
  EOF

  type = object({
    default_vpc            = optional(map(string))
    default_route_table    = optional(map(string))
    default_network_acl    = optional(map(string))
    default_security_group = optional(map(string))
  })

  default = {}
}

######################################################################
