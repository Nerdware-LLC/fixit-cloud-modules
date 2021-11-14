###################################################
### OUTPUTS

output "Organization" {
  value = data.tfe_organization.Nerdware
}

output "Workspaces" {
  value = {
    for key, value in tfe_workspace.map : key => value
    if key != "vcs_repo"
  }
  /* The "vcs_repo" object is filtered out because it 
  contains sensitive variable value "oauth_token_id" */
}

###################################################
