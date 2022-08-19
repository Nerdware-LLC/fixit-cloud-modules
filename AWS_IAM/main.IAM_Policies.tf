######################################################################
### AWS IAM
######################################################################
### IAM Policies

resource "aws_iam_policy" "map" {
  for_each = var.iam_policies

  name        = each.key
  policy      = data.aws_iam_policy_document.map[each.key].json
  description = each.value.description
  path        = coalesce(each.value.path, "/")
  tags        = each.value.tags
}

#---------------------------------------------------------------------

data "aws_iam_policy_document" "map" {
  for_each = var.iam_policies

  /* override_policy_documents is used here in lieu of source_policy_documents,
  because the source_ property requires each statement to have a unique Sid. */
  override_policy_documents = each.value.policy_json != null ? [each.value.policy_json] : null

  dynamic "statement" {
    for_each = each.value.statements != null ? each.value.statements : []

    content {
      sid    = statement.value.sid
      effect = title(statement.value.effect)

      dynamic "principals" {
        for_each = statement.value.principals != null ? statement.value.principals : {}

        content {
          type = principals.key # "AWS", "Service", or "Federated"
          identifiers = [
            for principal in principals.value : try(
              aws_iam_role.map[principal].arn,                    # <-- check if "principal" is a Role name
              aws_iam_openid_connect_provider.map[principal].arn, # <-- check if "principal" is an OIDC Provider name
              principal                                           # <-- if neither, pass "principal" as-is
            )
          ]
        }
      }

      actions   = statement.value.actions
      resources = statement.value.resources

      dynamic "condition" {
        for_each = statement.value.conditions != null ? statement.value.conditions : {}

        content {
          test     = condition.key          # IAM condition operator (e.g., "StringEquals", "ArnLike")
          variable = condition.value.key    # IAM condition key (e.g., "aws:username", "aws:SourceArn")
          values   = condition.value.values # IAM condition values (e.g., ["arn:aws:iam::111111111111:role/Foo"])
        }
      }
    }
  }
}

######################################################################
