###################################################
### Terraform Cloud

data "tfe_organization" "Nerdware" {
  name = "Nerdware"
}

resource "tfe_workspace" "map" {
  for_each = var.workspaces

  organization      = tfe_organization.Nerdware.name
  name              = each.key
  description       = each.value.description
  working_directory = each.value.modules_repo_dir
}

locals {
  /* This local provides a flat list of all workspace variable configs, along 
  with each variables respective "workspace_id" value. Note that variables
  provided via var.variables_for_all_workspaces are included as well */
  all_vars_with_workspace_ids = flatten([
    for ws_name, ws_config in var.workspaces : [
      [
        for ws_var_obj in ws_config.variables : merge(ws_var_obj, {
          workspace_id = tfe_workspace.map[ws_name].id
        })
      ],
      [ # Here we add the variables in var.variables_for_all_workspaces
        for all_ws_var_obj in var.variables_for_all_workspaces : merge(all_ws_var_obj, {
          workspace_id = tfe_workspace.map[ws_name].id
        })
      ]
    ]
  ])
}

resource "tfe_variable" "map" {
  for_each = {
    for ws_var in local.all_vars_with_workspace_ids : ws_var.key => ws_var
  }

  workspace_id = each.value.workspace_id
  key          = each.key
  value        = each.value.value
  description  = each.value.description
  category     = each.value.is_env_var == true ? "env" : "terraform"
  hcl          = each.value.is_value_hcl == true
  sensitive    = each.value.is_sensitive == true
}

###################################################
