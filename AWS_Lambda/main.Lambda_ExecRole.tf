######################################################################
### AWS Lambda Function Execution Role

resource "aws_iam_role" "Lambda_ExecRole" {
  name        = var.execution_role.name
  description = var.execution_role.description
  path        = coalesce(var.execution_role.path, "/")
  tags        = var.execution_role.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = {
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }
  })
}

#---------------------------------------------------------------------

resource "aws_iam_policy" "Lambda_ExecRole_Policies_Map" {
  for_each = var.execution_role.attach_policies != null ? var.execution_role.attach_policies : {}

  name        = each.key
  policy      = data.aws_iam_policy_document.Lambda_ExecRole_Policies_Map[each.key].json
  description = each.value.description
  path        = coalesce(each.value.path, "/")
  tags        = each.value.tags
}

#---------------------------------------------------------------------

data "aws_iam_policy_document" "Lambda_ExecRole_Policies_Map" {
  for_each = var.execution_role.attach_policies != null ? var.execution_role.attach_policies : {}

  /* override_policy_documents is used here in lieu of source_policy_documents,
  because the source_ property requires each statement to have a unique Sid. */
  override_policy_documents = each.value.policy_json != null ? [each.value.policy_json] : null

  dynamic "statement" {
    for_each = each.value.statements != null ? each.value.statements : []

    content {
      sid       = statement.value.sid
      effect    = title(statement.value.effect)
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

#---------------------------------------------------------------------

resource "aws_iam_role_policy_attachment" "Lambda_ExecRole" {
  for_each = toset(flatten([
    var.execution_role.attach_policies != null ? keys(var.execution_role.attach_policies) : [],
    var.execution_role.attach_policy_arns != null ? var.execution_role.attach_policy_arns : []
  ]))

  role = aws_iam_role.Lambda_ExecRole.name
  policy_arn = try(
    aws_iam_policy.Lambda_ExecRole_Policies_Map[each.key].arn, # <-- for policies created in same module call
    each.key                                                   # <-- external policy ARNs
  )
}

######################################################################
