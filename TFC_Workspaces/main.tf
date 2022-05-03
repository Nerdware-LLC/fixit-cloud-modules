######################################################################
### Terraform Cloud

data "tfe_organization" "Nerdware" {
  name = "Nerdware"
}

#---------------------------------------------------------------------

resource "tfe_workspace" "map" {
  for_each = var.workspaces

  organization   = data.tfe_organization.Nerdware.name
  name           = each.key
  description    = each.value.description
  execution_mode = each.value.remote_execution != null ? "remote" : "local"

  working_directory   = each.value.modules_repo_dir
  allow_destroy_plan  = coalesce(each.value.is_destroyable, false)
  speculative_enabled = coalesce(each.value.is_speculative_plan_enabled, false)
  terraform_version   = "1.1.5"
  queue_all_runs      = false

  dynamic "vcs_repo" {
    for_each = (
      try(each.value.remote_execution.is_vcs_connected, false)
      ? ["Nerdware-LLC/fixit-cloud-modules"]
      : []
    )
    content {
      identifier         = vcs_repo.value
      branch             = "main"
      ingress_submodules = false
      # The below variable is stored/provided by TF Cloud - do not fiddle with it.
      oauth_token_id = var.fixit-cloud-modules-repo_github-oauth-token-id
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
