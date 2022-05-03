######################################################################
### OUTPUTS

output "Organization" {
  description = "The TFC Organization data-block attributes."
  value       = data.tfe_organization.Nerdware
}

output "Workspaces" {
  description = "Map of TFC Workspace resource objects."
  value       = tfe_workspace.map
  sensitive   = true
}

######################################################################
