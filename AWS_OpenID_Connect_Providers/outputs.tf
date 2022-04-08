######################################################################
### Outputs

output "OpenID_Connect_Providers" {
  description = "Map of IAM OpenID Connect (OIDC) Identity Provider resource objects."
  value       = aws_iam_openid_connect_provider.map
}

output "OpenID_Connect_Provider_Roles" {
  description = "Map of OpenID Connect (OIDC) Identity Provider Role resource objects."
  value       = aws_iam_role.OIDC_IdP_Roles_map
}

######################################################################
