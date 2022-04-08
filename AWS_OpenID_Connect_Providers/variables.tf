######################################################################
### Variables

variable "openID_connect_providers" {
  description = <<-EOF
  Map of OpenID Connect (OIDC) Identity Provider config objects. The top-level map keys
  should be human-readable IdP names - they're attached to the "OpenID_Connect_Providers"
  output object to simplify finding any resource outputs you might need. For "built-in"
  identity providers that don't require an IdP to be created within IAM (Amazon Cognito,
  Google, and Facebook), exclude the optional "iam_oidc_idp_config" property. Each OIDC
  IdP must be associated with an IAM Role, which is configurable via the "iam_role"
  property object. The "iam_role.assume_role_policy_conditions" property must be a valid
  JSON-encoded string which yields valid AssumeRole Policy conditions when provided to
  the jsondecode Terraform fn. For "built-in" IdP's, the AssumeRole Policy "Principal"
  will be set to the value of the "iam_role.built_in_idp_principal_url" property, which
  must be set to the URL the built-in IdP uses for OIDC federation. For IAM IdP's that
  aren't "built-in", the "Principal" field will be populated with the IdP's ARN and
  therefore should not be included in the argument. For more info on OIDC IdP's, please
  refer to the AWS documentation regarding OpenID Connect Identity Providers:
  https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html.
  EOF

  type = map(object({
    iam_oidc_idp_config = optional(object({
      url             = string
      client_id_list  = list(string)
      thumbprint_list = list(string)
      tags            = optional(map(string))
    }))
    iam_role = object({
      name                          = string
      description                   = optional(string)
      tags                          = optional(map(string))
      built_in_idp_principal_url    = optional(string)
      assume_role_policy_conditions = string
    })
  }))

  validation {
    condition = alltrue([
      for idp in values(var.openID_connect_providers) : can(jsondecode(idp.iam_role.assume_role_policy_conditions))
    ])
    error_message = "All \"assume_role_policy_conditions\" values must be valid JSON-encoded strings."
  }
}

######################################################################
