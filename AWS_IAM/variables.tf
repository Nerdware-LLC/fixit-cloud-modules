######################################################################
### INPUT VARIABLES

variable "iam_policies" {
  description = <<-EOF
  Map of custom IAM Policy names/IDs to policy config objects. Policies may
  be provided either as JSON-encoded strings via the "policy_json" property,
  or as statement config objects within "statements". Within statement config
  objects, "principals" takes the same shape as IAM policy doc - i.e., a map
  with keys "AWS", "Service", and/or "Federated" set to lists of IAM entities
  of each respective type. Roles and OIDC Providers which are created within
  the same module call can be referenced by name, and the ARN will replace the
  name in the final policy document. IAM Roles included in "var.iam_roles" may
  also reference these policies by name in their "attach_policies" property.
  EOF

  type = map(
    # map keys: IAM Policy names/IDs
    object({
      policy_json = optional(string)
      statements = optional(list(object({
        sid    = optional(string)
        effect = string
        principals = optional(map(
          # map keys: "AWS", "Service", and/or "Federated"
          list(string)
        ))
        actions   = list(string)
        resources = optional(list(string))
        conditions = optional(map(
          # map keys: IAM condition operators (e.g., "StringEquals", "ArnLike")
          object({
            key    = string
            values = list(string)
          })
        ))
      })))
      description = optional(string)
      path        = optional(string)
      tags        = optional(map(string))
    })
  )

  default = {}

  # Ensure each policy has either "policy_json" or "statements"
  validation {
    condition = alltrue([
      for policy in values(var.iam_policies) : can(policy.policy_json) || can(policy.statements)
    ])
    error_message = "All IAM policy inputs must have either \"policy_json\" or \"statements\"."
  }
}

#---------------------------------------------------------------------

variable "iam_roles" {
  description = <<-EOF
  Map of IAM Role names to role config objects. The role's AssumeRole policy
  must be configured using one of the two "assume_role_" properties. You can
  provide a complete AssumeRole policy document as a JSON-encoded string via
  the "assume_role_policy_json" property, or you can provide one or more
  statement config objects to "assume_role_policy_statements". The shape of
  "principals", "actions", and "conditions" must reflect valid IAM policy
  syntax. For roles intended to be assumed by OIDC Identity Providers created
  within the same module call, use the OIDC IdPs name in "principals.Federated"
  list (name must match the key you use in "var.openID_connect_providers"), and
  set "should_lookup_oidc_principals" to true - the ARN will then be inserted
  into the policy document.
  To attach policies to your roles, you can include ARNs of existing policies
  (custom or AWS-managed) in the "attach_policies" list property. To attach
  policies you've defined in "var.iam_policies", you can simply include the
  names of those policies in this list as well.
  EOF

  type = map(
    # map keys: IAM Role names
    object({
      description             = optional(string)
      path                    = optional(string)
      assume_role_policy_json = optional(string)
      assume_role_policy_statements = optional(list(object({
        sid    = optional(string)
        effect = string
        principals = map(
          # map keys: "AWS", "Service", and/or "Federated"
          list(string)
        )
        should_lookup_oidc_principals = optional(bool)
        actions                       = list(string)
        conditions                    = optional(map(map(list(string))))
      })))
      attach_policies = optional(list(string))
      tags            = optional(map(string))
    })
  )

  default = {}

  # Ensure each role has either "assume_role_policy_json" or "assume_role_policy_statements"
  validation {
    condition = alltrue([
      for role in values(var.iam_roles) : can(role.assume_role_policy_json) || can(role.assume_role_policy_statements)
    ])
    error_message = "All IAM role inputs must have either \"assume_role_policy_json\" or \"assume_role_policy_statements\"."
  }
}

#---------------------------------------------------------------------

variable "iam_service_linked_roles" {
  description = <<-EOF
  Map of IAM Service-Linked Role URLs (e.g., "elasticbeanstalk.amazonaws.com") to
  config objects for each respective service-linked role.
  EOF

  type = map(
    # map keys: AWS service URL
    object({
      description = optional(string)
      tags        = optional(map(string))
    })
  )

  default = {}
}

#---------------------------------------------------------------------

variable "instance_profiles" {
  description = <<-EOF
  Map of Instance Profile names to config objects. To associate an instance
  profile with an existing role (one not created in the same module call),
  use "role_arn". To associate a role included in var.iam_roles, provide
  the name of the desired role to "role_name".
  EOF

  type = map(
    # map keys: Instance Profile names
    object({
      path      = optional(string)
      role_arn  = optional(string)
      role_name = optional(string)
      tags      = optional(map(string))
    })
  )

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

#---------------------------------------------------------------------

variable "openID_connect_providers" {
  description = <<-EOF
  (Optional) Map of OpenID Connect (OIDC) Identity Provider names to config objects.
  "Built-in" identity providers which don't require an IdP to be created within IAM
  (Amazon Cognito, Google, and Facebook), don't require explicit creation within AWS.
  To associate an OIDC IdP with an existing role (one not created in the same module
  call), use "role_arn". To associate a role included in var.iam_roles, provide the
  name of the desired role to "role_name".
  EOF

  type = map(
    # map keys: OIDC IdP names
    object({
      url             = string
      client_id_list  = list(string)
      thumbprint_list = list(string)
      tags            = optional(map(string))
    })
  )

  default = {}
}

######################################################################
