######################################################################
### AWS IAM
######################################################################
### IAM OpenID Connect Identity Providers

resource "aws_iam_openid_connect_provider" "map" {
  for_each = var.openID_connect_providers

  url            = each.value.url
  client_id_list = each.value.client_id_list
  thumbprint_list = [
    # AWS lowercases all letters in the tp, so we lower() them here to avoid constant-diffs problem.
    for thumbprint in each.value.thumbprint_list : lower(thumbprint)
  ]
  tags = each.value.tags
}

######################################################################
