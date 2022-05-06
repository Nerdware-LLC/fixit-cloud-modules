######################################################################
### INPUT VARIABLES

variable "custom_iam_policies" {
  description = <<-EOF
  Map of custom IAM Policy names to policy config objects. For each policy,
  the "policy_json" property must be a JSON-encoded string. IAM Roles included
  in var.iam_roles may reference these policies by name in their "policies"
  property.
  EOF

  type = map(object({
    policy_json = string
    description = optional(string)
    path        = optional(string)
    tags        = optional(map(string))
  }))

  default = {}
}

#---------------------------------------------------------------------

variable "iam_roles" {
  description = <<-EOF
  Map of IAM Role names to role config objects. The role's AssumeRole
  policy may be configured in one of two ways: you can either provide a
  complete AssumeRole policy document as a JSON-encoded string via the
  "assume_role_policy_json" property, or you can simply provide the
  fully-qualified domain name of an AWS service (e.g., "ec2.amazonaws.com")
  via the "service_assume_role" property, and a basic condition-less
  AssumeRole policy will be created for you using that service.
  To attach policies to your roles, you can include ARNs of existing
  policies (custom or AWS-managed) in the "policies" list property. To
  attach policies you've defined in var.custom_iam_policies, you can simply
  include the names of those policies in this list as well.
  EOF

  type = map(object({
    description             = optional(string)
    path                    = optional(string)
    assume_role_policy_json = optional(string)
    service_assume_role     = optional(string)
    policies                = optional(list(string))
    tags                    = optional(map(string))
  }))

  default = {}

  validation {
    condition = alltrue([
      # Each role must have either "assume_role_policy_json" or "service_assume_role"
      for role_config in values(var.iam_roles) : anytrue([
        role_config.assume_role_policy_json != null && can(jsondecode(role_config.assume_role_policy_json)),
        role_config.service_assume_role != null
      ])
    ])
    error_message = "Each role must have either service_assume_role, or assume_role_policy_json as valid JSON."
  }
}

#---------------------------------------------------------------------

variable "instance_profiles" {
  description = <<-EOF
  Map of Instance Profile names to config objects. To associate an instance
  profile with an existing role (one not created in the same module call),
  use "role_arn". To associate a role included in var.iam_roles, provide
  the name of the desired role to "role_name".
  EOF

  type = map(object({
    path      = optional(string)
    role_arn  = optional(string)
    role_name = optional(string)
    tags      = optional(map(string))
  }))

  default = {}

  validation {
    condition = alltrue([
      # Each InstProf must have either "role_arn" or "role_name"
      for profile_config in values(var.instance_profiles) : (
        profile_config.role_arn != null || profile_config.role_name != null
      )
    ])
    error_message = "Each instance profile must either have role_arn or role_name."
  }
}

######################################################################
