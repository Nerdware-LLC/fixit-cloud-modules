######################################################################
### INPUT VARIABLES

variable "terraform_cloud_organization" {
  description = "The Terraform Cloud Organization name."
  type        = string
}

variable "workspaces" {
  description = <<-EOF
  Map of TF Cloud Workspace names to corresponding workspace config objects.
  The optional boolean properties all default to false. If "terraform_version"
  is provided, the specified semver will be used to constrain the versions of
  TF permitted to run within the workspace. Use the "remote_execution" property
  to configure workspace plan/apply operations to run remotely on TFC VMs instead
  of your local machine. With remote execution, you can also setup the VCS-driven
  workflow via the "vcs_config" property, which will cause apply operations to be
  initiated by new changes to "vcs_repo.branch" (default: "main") rather than via
  manual CLI/API calls. Note that enabling the VCS-driven workflow will DISABLE
  the ability to trigger runs via the CLI/API, which at this time can only be
  reversed by manually removing the repository from the workspace via the TF
  Cloud console. Instructions for obtaining a "vcs_oauth_token_id" for GitHub
  can be found at https://www.terraform.io/cloud-docs/vcs/github.
  EOF

  type = map(object({
    description             = optional(string)
    tag_names               = optional(list(string))
    working_directory       = optional(string)
    terraform_version       = optional(string)
    allow_destroy_plans     = optional(bool)
    allow_speculative_plans = optional(bool)
    should_queue_all_runs   = optional(bool)
    remote_execution = optional(object({
      variables = optional(list(object({
        key          = string
        value        = string
        description  = optional(string)
        is_env_var   = optional(bool)
        is_value_hcl = optional(bool)
        is_sensitive = optional(bool)
      })))
      vcs_config = optional(object({
        identifier         = string # e.g., Nerdware-LLC/fixit-cloud-modules
        vcs_oauth_token_id = string
        branch             = optional(string) # default "main"
        ingress_submodules = optional(bool)   # default false
      }))
    }))
  }))
}

######################################################################
