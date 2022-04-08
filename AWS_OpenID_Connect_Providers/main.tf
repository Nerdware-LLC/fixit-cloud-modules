######################################################################
### OpenID Connect (OIDC) Providers

resource "aws_iam_openid_connect_provider" "map" {
  for_each = {
    # Filter out "built-in" IdP's which don't need to be created in IAM.
    for idp_name, idp_config in var.openID_connect_providers : idp_name => idp_config
    if idp_config.iam_oidc_idp_config != null
  }

  url            = each.value.iam_oidc_idp_config.url
  client_id_list = each.value.iam_oidc_idp_config.client_id_list
  thumbprint_list = [
    # AWS lowercases all letters in the tp, so we lower() them here to avoid constant-diffs problem.
    for thumbprint in each.value.iam_oidc_idp_config.thumbprint_list : lower(thumbprint)
  ]
  tags = each.value.iam_oidc_idp_config.tags
}

#---------------------------------------------------------------------

resource "aws_iam_role" "OIDC_IdP_Roles_map" {
  for_each = var.openID_connect_providers

  name        = each.value.iam_role.name
  description = each.value.iam_role.description
  tags        = each.value.iam_role.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = {
      Sid    = "Allow_OIDC_IdP_AssumeRole"
      Effect = "Allow"
      Principal = {
        Federated = coalesce(
          each.value.iam_role.built_in_idp_principal_url,
          aws_iam_openid_connect_provider.map[each.key].arn
        )
      }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = jsondecode(each.value.iam_role.assume_role_policy_conditions)
    }
  })
}

######################################################################
