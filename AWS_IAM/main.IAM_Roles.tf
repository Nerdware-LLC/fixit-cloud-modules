######################################################################
### AWS IAM
######################################################################
### IAM Roles

# TODO Add IAM Users and Groups

resource "aws_iam_role" "map" {
  for_each = var.iam_roles

  name        = each.key
  description = each.value.description
  path        = coalesce(each.value.path, "/")
  tags        = each.value.tags

  assume_role_policy = (
    each.value.assume_role_policy_json != null
    ? each.value.assume_role_policy_json
    : jsonencode({
      Version = "2012-10-17"
      Statement = [
        for statement in each.value.assume_role_policy_statements : {
          Effect = statement.effect
          Principal = ( # see if we need to look up an OIDC Provider ARN
            statement.should_lookup_oidc_principals != true
            ? statement.principals
            : merge(
              statement.principals,
              {
                Federated = [
                  for principal in statement.principals.Federated : (
                    can(aws_iam_openid_connect_provider.map[principal].arn)
                    ? aws_iam_openid_connect_provider.map[principal].arn
                    : principal
                  )
                ]
              }
            )
          )
          Action    = statement.actions
          Condition = statement.conditions
        }
      ]
    })
  )
}

#---------------------------------------------------------------------
### IAM Service-Linked Roles

resource "aws_iam_service_linked_role" "map" {
  for_each = var.iam_service_linked_roles

  aws_service_name = each.key
  description      = each.value.description
  tags             = each.value.tags
}

#---------------------------------------------------------------------
### IAM Role Policy Attachments

resource "aws_iam_role_policy_attachment" "map" {
  /* Since neither role names nor policy names/ARNs can serve as unique keys
  within a map, we use both in combination to create keys out of jsonencoded
  objects with keys "role" and "policy". Note if user provided a policy
  name, the ARN is obtained from the aws_iam_policy resource.  */
  for_each = toset(flatten([
    for role_name, role_config in var.iam_roles : [
      for policy_name_or_arn in try(coalesce(role_config.attach_policies, []), []) : jsonencode({
        role   = role_name
        policy = policy_name_or_arn
      })
    ]
  ]))

  role = jsondecode(each.value).role
  policy_arn = (
    can(aws_iam_policy.map[jsondecode(each.value).policy])
    ? aws_iam_policy.map[jsondecode(each.value).policy].arn # <-- if policy was created in same module call
    : jsondecode(each.value).policy                         # <-- if policy is the ARN of an existing policy
  )

  /* The purpose of this depends_on is to ensure all referenced role/policy
  resources exist before requests are submitted to attach them.  */
  depends_on = [aws_iam_role.map, aws_iam_policy.map]
}

######################################################################
