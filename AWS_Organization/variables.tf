######################################################################
### INPUT VARIABLES

variable "organization_config" {
  description = "Config object for an AWS Organization."

  type = object({
    org_trusted_services = list(string)
    enabled_policy_types = list(string)
  })
}

#---------------------------------------------------------------------

variable "organizational_units" {
  description = <<-EOF
  Map of Organizational Unit names to config objects. "parent" must be
  "root" or the name of another OU within var.organizational_units.
  EOF

  type = map(
    # map keys:
    object({
      parent = string
      tags   = optional(map(string))
    })
  )

  validation {
    condition = alltrue([
      for ou_parent in values(var.organizational_units)[*].parent : contains(
        flatten(["root", keys(var.organizational_units)]),
        ou_parent
      )
    ])
    error_message = "All \"parent\" values must either be \"root\" or the name of another Organizational Unit."
  }
}

#---------------------------------------------------------------------

variable "member_accounts" {
  description = <<-EOF
  Map of Organization Account names to config objects. Note that AWS Organization
  best practices entails attaching organization policies to OUs - not accounts - so
  this module does not permit member accounts to have a "parent" value of "root".
  The "should_allow_iam_user_access_to_billing" property defaults to "true",
  and "org_account_access_role_name" defaults to "OrganizationAccountAccessRole".
  EOF

  type = map(
    # map keys:
    object({
      parent                                  = string
      email                                   = string
      should_allow_iam_user_access_to_billing = optional(bool)
      org_account_access_role_name            = optional(string)
      tags                                    = optional(map(string))
    })
  )

  validation {
    condition = alltrue([
      for parent in values(var.member_accounts)[*].parent : parent != "root"
    ])
    error_message = "All \"parent\" values must be the name of an Organizational Unit, not \"root\"."
  }
}

#---------------------------------------------------------------------

variable "admin_sso_config" {
  description = "Map of SSO Administrator Object for configuring administrator access to accounts via AWS SSO."

  type = object({
    sso_group_name             = string
    permission_set_name        = optional(string)
    permission_set_description = optional(string)
    permission_set_tags        = optional(map(string))
    session_duration           = optional(number)
  })

  # Ensure "session_duration", if provided, is a number between 1-12.
  validation {
    condition = var.admin_sso_config.session_duration == null || (
      1 <= var.admin_sso_config.session_duration && var.admin_sso_config.session_duration <= 12
    )
    error_message = "\"session_duration\" must be either a number between 1-12 or null."
  }
}

#---------------------------------------------------------------------

variable "organization_policies" {
  description = <<-EOF
  Map organization policy names to config objects. The "target" property indicates
  to which organization entity the policy should be attached; valid values are "root"
  and the name of any OU. The "type" for each policy config object can be one one of
  the following: SERVICE_CONTROL_POLICY, AISERVICES_OPT_OUT_POLICY, BACKUP_POLICY,
  or TAG_POLICY. "statement" must be a valid JSON string. Please refer to AWS docs
  for info regarding how to structure each policy type.
  EOF

  type = map(
    # map keys: organization policy names
    object({
      target      = string
      type        = string
      description = optional(string)
      statement   = string
      tags        = optional(map(string))
    })
  )

  default = null

  validation {
    condition = (
      var.organization_policies == null || alltrue([
        for policy in values(var.organization_policies) : contains(
          ["SERVICE_CONTROL_POLICY", "AISERVICES_OPT_OUT_POLICY", "BACKUP_POLICY", "TAG_POLICY"],
          policy.type
        )
      ])
    )
    error_message = "Invalid \"type\" property on one or more organization policies."
  }
}

######################################################################
