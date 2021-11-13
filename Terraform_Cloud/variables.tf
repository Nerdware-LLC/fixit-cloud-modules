###################################################
### INPUT VARIABLES

variable "workspaces" {
  description = <<-EOF
  A map of TF Cloud Workspace config objects. The "modules_repo_dir" 
  param should be the name of a directory in the Nerdware 
  fixit-cloud-modules repository (e.g., "/Terraform_Cloud"). Each
  optional boolean value defaults to "false".
  EOF
  type = map(object({
    description      = optional(string)
    modules_repo_dir = string
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

variable "variables_for_all_workspaces" {
  description = <<-EOF
  If some variables need to be included in ALL workspaces, you can
  list them here just once instead of repeating them throughout the
  "workspaces" variable.
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

###################################################
