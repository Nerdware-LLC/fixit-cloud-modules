######################################################################
### INPUT VARIABLES

variable "workspaces" {
  description = <<-EOF
  Map of TF Cloud Workspace config objects. The optional boolean properties
  all default to false. "is_vcs_connected", if "true", will connect the
  workspace to the fixit-cloud-modules repo. Note that enabling the VCS-driven
  workflow will DISABLE the ability to trigger runs via the CLI/API, which at
  this time can only be reversed by manually removing the repository from the
  workspace via the TF Cloud console. The "modules_repo_dir" param should be
  the name of a dir in the Nerdware fixit-cloud-modules repository (e.g.,
  "Terraform_Cloud").
  EOF
  type = map(object({
    description                 = optional(string)
    modules_repo_dir            = optional(string)
    is_vcs_connected            = optional(bool)
    is_destroyable              = optional(bool)
    is_speculative_plan_enabled = optional(bool)
    variables = optional(list(object({
      key          = string
      value        = string
      description  = optional(string)
      is_env_var   = optional(bool)
      is_value_hcl = optional(bool)
      is_sensitive = optional(bool)
    })))
  }))
}

#---------------------------------------------------------------------

variable "variables_for_all_workspaces" {
  description = <<-EOF
  Map of variable-names to objects which configure them. The vars included
  here will be available to ALL workspaces within the organization.
  EOF
  type = list(object({
    key          = string
    value        = string
    description  = optional(string)
    is_env_var   = optional(bool)
    is_value_hcl = optional(bool)
    is_sensitive = optional(bool)
  }))
  default = []
}

variable "fixit-cloud-modules-repo_github-oauth-token-id" {
  description = <<-EOF
  This variable value is stored in and provided by TF Cloud, and
  should *NOT* be provided as an input variable. This declaration
  exists solely to silence CLI warnings/errors.
  EOF
  type        = string
  sensitive   = true
}

######################################################################
