######################################################################
### OUTPUTS

output "Workspaces" {
  description = "Map of TFC Workspace resource objects."
  value       = tfe_workspace.map
}

output "Workspace_Variables" {
  description = "Map of TFC Workspace Variable resources (sensitive)."
  value       = tfe_variable.map
  sensitive   = true
}

######################################################################
