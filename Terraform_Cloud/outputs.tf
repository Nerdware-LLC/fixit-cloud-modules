###################################################
### OUTPUTS

output "Organization" {
  value = data.tfe_organization.Nerdware
}

output "Workspaces" {
  value = {
    for key, value in tfe_workspace.map : key => value
    if !can(nonsensitive(value)) && key != "vcs_repo"
  }
}

###################################################
