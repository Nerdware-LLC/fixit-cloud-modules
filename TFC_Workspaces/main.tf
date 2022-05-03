######################################################################
### Terraform Cloud

data "tfe_organization" "Nerdware" {
  name = "Nerdware"
}

#---------------------------------------------------------------------

resource "tfe_workspace" "map" {
  for_each = var.workspaces

  organization      = data.tfe_organization.Nerdware.name
  name              = each.key
  description       = each.value.description
  execution_mode    = each.value.remote_execution != null ? "remote" : "local"
  working_directory = each.value.working_directory

  terraform_version   = each.value.terraform_version
  allow_destroy_plan  = coalesce(each.value.allow_destroy_plans, false)
  speculative_enabled = coalesce(each.value.allow_speculative_plans, false)
  queue_all_runs      = coalesce(each.value.should_queue_all_runs, false)

  dynamic "vcs_repo" {
    for_each = (
      try(each.value.remote_execution.vcs_config, null) != null
      ? [each.value.remote_execution.vcs_config]
      : []
    )
    content {
      identifier         = vcs_repo.value.identifier
      oauth_token_id     = vcs_repo.value.oauth_token_id
      branch             = coalesce(vcs_repo.value.branch, "main")
      ingress_submodules = coalesce(vcs_repo.value.ingress_submodules, false)
    }
  }
}

#---------------------------------------------------------------------

resource "tfe_variable" "map" {
  for_each = {
    # Merge workspace_id into each workspace variable
    for var_obj in flatten([
      for workspace_name, workspace_config in var.workspaces : [
        for var_obj in try(workspace_config.remote_execution.variables, []) :
        merge(var_obj, { workspace_id = tfe_workspace.map[workspace_name].id })
      ]
    ]) : var_obj.key => var_obj # <-- each.key, each.value
  }

  workspace_id = each.value.workspace_id
  key          = each.key
  value        = each.value.value
  description  = each.value.description
  category     = each.value.is_env_var == true ? "env" : "terraform"
  hcl          = each.value.is_value_hcl == true
  sensitive    = each.value.is_sensitive == true
}

######################################################################
