######################################################################
### AWS ECR Repo Policies

resource "aws_ecr_repository_policy" "map" {
  for_each = var.repositories

  repository = each.key

  policy = (
    each.value.policy_config.custom_statements_json == null
    ? data.aws_iam_policy_document.Repo_Policies_Map[each.key].json
    : jsonencode({
      Version = "2012-10-17"
      Statement = flatten(
        jsondecode(data.aws_iam_policy_document.Repo_Policies_Map[each.key].json).Statement,
        jsondecode(each.value.policy_config.custom_statements_json)
      )
  }))

  depends_on = [aws_ecr_repository.map]
}

data "aws_iam_policy_document" "Repo_Policies_Map" {
  for_each = var.repositories

  # ALLOW PUSH AND PULL ACCESS TO AWS PRINCIPALS
  dynamic "statement" {
    for_each = (
      each.value.policy_config.allow_push_and_pull_images != null
      ? [each.value.policy_config.allow_push_and_pull_images]
      : []
    )

    content {
      sid    = "EcrRepoAllowPushPull"
      effect = "Allow"

      principals {
        type        = statement.value.principals.type
        identifiers = statement.value.principals.identifiers
      }

      actions = [
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:CompleteLayerUpload",
        "ecr:DescribeImages",
        "ecr:DescribeRepositories",
        "ecr:GetAuthorizationToken", # <-- required for CLI authentication
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetRepositoryPolicy",
        "ecr:InitiateLayerUpload",
        "ecr:ListImages",
        "ecr:PutImage",
        "ecr:UploadLayerPart",
      ]

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

  # ALLOW CODEBUILD ACCESS
  dynamic "statement" {
    for_each = (
      each.value.policy_config.allow_codebuild_access != null
      ? [each.value.policy_config.allow_codebuild_access]
      : []
    )

    content {
      sid    = "EcrRepoAllowCodebuild"
      effect = "Allow"

      principals {
        type        = "Service"
        identifiers = "codebuild.amazonaws.com"
      }

      actions = [
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer"
      ]

      condition {
        test     = "ArnLike"
        variable = "aws:SourceArn"
        values   = statement.value.codebuild_project_source_arns
      }

      condition {
        test     = "StringEquals"
        variable = "aws:SourceAccount"
        values   = statement.value.codebuild_account_ids
      }

      dynamic "condition" {
        for_each = statement.value.custom_conditions != null ? statement.value.custom_conditions : {}

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
