###################################################
### OUTPUTS

output "Organization" {
  value = data.tfe_organization.Nerdware
}

output "Workspaces" {
  value = tfe_workspace.map
}

###################################################