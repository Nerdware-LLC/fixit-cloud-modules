###################################################
### OUTPUTS

output "Organization" {
  value = data.tfe_organization.Nerdware
}

locals {
  workspaces_output = {
    for ws_name, ws_config in tfe_workspace.map : ws_name => {
      for key, value in ws_config : key => value if !can(nonsensitive(value)) && key != "vcs_repo"
    }
  }
}

output "Workspaces" {
  value = local.workspaces_output
}

###################################################
