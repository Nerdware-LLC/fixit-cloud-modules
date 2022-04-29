######################################################################
### INPUT VARIABLES

variable "organization_config" {
  description = <<-EOF
  A config object for an AWS Organization. For more info on these
  parameters, please refer to the documentation for AWS Organizations and
  the relevant API/CLI commands. Note that "should_enable_all_features"
  defaults to "true".
  EOF

  type = object({
    org_trusted_services = list(string)
    enabled_policy_types = list(string)
  })
}

#---------------------------------------------------------------------

variable "organizational_units" {
  description = <<-EOF
  A map of config objects for orginizational units within an AWS
  Organization. The keys of the map are names of OU entities, with each
  respective value pointing to the OU's config object with params identifying
  the OU's parent entity ("root" or the name of another OU) and optional tags.
  EOF

  type = map(object({
    parent = string
    tags   = optional(map(string))
  }))

  validation {
    condition = alltrue([
      for org_unit_parent in values(var.organizational_units)[*].parent : contains(
        flatten(["root", keys(var.organizational_units)]),
        org_unit_parent
      )
    ])
    error_message = "All \"parent\" values must either be \"root\" or the name of another organizational unit."
  }
}

#---------------------------------------------------------------------

variable "member_accounts" {
  description = <<-EOF
  A config object for child/member accounts within an AWS Organization.
  The keys of the object are names of child accounts, with each respective
  value pointing to the account's config object with params identifying the
  parent organizational unit and other attributes. Note that best practices
  entails attaching organization policies to OUs - not accounts - so this
  module does not permit member accounts to have a "parent" value of "root".
  The "should_allow_iam_user_access_to_billing" property defaults to "true",
  and "org_account_access_role_name" defaults to "OrganizationAccountAccessRole".
  EOF

  type = map(object({
    parent                                  = string
    email                                   = string
    should_allow_iam_user_access_to_billing = optional(bool)
    org_account_access_role_name            = optional(string)
    tags                                    = optional(map(string))
  }))

  validation {
    condition = alltrue([
      for parent in values(var.member_accounts)[*].parent : parent != "root"
    ])
    error_message = "All \"parent\" values must be the name of an organizational unit, not \"root\"."
  }
}

#---------------------------------------------------------------------

variable "admin_sso_config" {
  description = <<-EOF
  An object for configuring administrator access to accounts via AWS SSO.
  Please note that SSO requires some setup in the console; for example,
  GROUPS and USERS cannot be created via the AWS provider - they must be
  created beforehand. For an overview of the default config values, please
  refer to the README.
  EOF

  type = object({
    sso_group_name             = optional(string)
    permission_set_name        = optional(string)
    permission_set_description = optional(string)
    permission_set_tags        = optional(map(string))
    session_duration           = optional(number)
  })

  default = {}

  validation {
    condition = anytrue([ # Either a number between 1-12, OR null.
      (
        tonumber(var.admin_sso_config.session_duration) >= 1 &&
        tonumber(var.admin_sso_config.session_duration) <= 12
      ),
      var.admin_sso_config.session_duration == null
    ])
    error_message = "\"session_duration\", if provided, must be a number between 1-12."
  }
}

#---------------------------------------------------------------------

variable "organization_policies" {
  description = <<-EOF
  Map policy names to organization policy config objects to provision
  organization policies. The "target" property indicates to which
  organization entity the policy should be attached; valid values are "root" and
  the name of any OU. The "type" for each policy config object can be one one of
  the following: SERVICE_CONTROL_POLICY, AISERVICES_OPT_OUT_POLICY, BACKUP_POLICY,
  or TAG_POLICY. "statement" must be a valid JSON string. Please refer to AWS docs
  for info regarding how to structure each policy type.
  EOF

  type = map(object({
    target      = string
    type        = string
    description = optional(string)
    statement   = string
    tags        = optional(map(string))
  }))

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
