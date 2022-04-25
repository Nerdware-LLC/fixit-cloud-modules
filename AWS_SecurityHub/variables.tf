######################################################################
### INPUT VARIABLES

variable "securityhub_organization_admin_account_id" {
  description = <<-EOF
  The ID of the account designated as the delegated administrator
  for the SecurityHub service. Must be applied by the Organization
  root account before any other resources can be applied.
  EOF

  type    = string
  default = null # will be null for all non-root accounts.
}

#---------------------------------------------------------------------

variable "securityhub_member_accounts" {
  description = <<-EOF
  List of account param objects for all accounts within the
  Organization. The Delegated Admin account needs this list to add
  each account to the Org's SecurityHub service. Each account-param
  object must include the account's ID and email.
  EOF

  type = map(object({
    id    = string
    email = string
  }))
  default = null # will be null for all non-SecHub-Admin accounts.
}

#---------------------------------------------------------------------

variable "standards_arns_by_region" {
  description = "Config object for enabling SecurityHub Standards by region."
  type = object({
    ap-northeast-1 = optional(list(string)) # Asia Pacific (Tokyo)
    ap-northeast-2 = optional(list(string)) # Asia Pacific (Seoul)
    ap-northeast-3 = optional(list(string)) # Asia Pacific (Osaka)
    ap-south-1     = optional(list(string)) # Asia Pacific (Mumbai)
    ap-southeast-1 = optional(list(string)) # Asia Pacific (Singapore)
    ap-southeast-2 = optional(list(string)) # Asia Pacific (Sydney)
    ca-central-1   = optional(list(string)) # Canada (Central)
    eu-north-1     = optional(list(string)) # Europe (Stockholm)
    eu-central-1   = optional(list(string)) # Europe (Frankfurt)
    eu-west-1      = optional(list(string)) # Europe (Ireland)
    eu-west-2      = optional(list(string)) # Europe (London)
    eu-west-3      = optional(list(string)) # Europe (Paris)
    sa-east-1      = optional(list(string)) # South America (São Paulo)
    us-east-1      = optional(list(string)) # US East (N. Virginia)
    us-east-2      = optional(list(string)) # US East (Ohio)
    us-west-1      = optional(list(string)) # US West (N. California)
    us-west-2      = optional(list(string)) # US West (Oregon)
  })
}

######################################################################
