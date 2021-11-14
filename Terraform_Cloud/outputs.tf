###################################################
### OUTPUTS

output "Organization" {
  value = data.tfe_organization.Nerdware
}

output "Workspaces" {
  value = {
    for ws_name, ws_config in tfe_workspace.map : ws_name => {
      for key, value in ws_config : key => value if !can(nonsensitive(value)) && key != "vcs_repo"
    }
  }
}

###################################################
