######################################################################
### AWS ECR Repositories

resource "aws_ecr_repository" "map" {
  for_each = var.repositories

  name = each.key
  image_tag_mutability = (
    coalesce(each.value.should_image_tags_be_immutabile, false)
    ? "IMMUTABLE"
    : "MUTABLE"
  )

  # tfsec rule ignored bc it's left to user to implement a KMS key
  # tfsec:ignore:aws-ecr-repository-customer-key
  encryption_configuration {
    type    = try(each.value.sse_config.type, "AES256")
    kms_key = try(each.value.sse_config.kms_key_arn, null)
  }

  image_scanning_configuration {
    /* This block is constant because it implements the default "Basic"
    scanning AWS provides to all ECR repositories. If "Enhanced" is
    enabled (aws_ecr_registry_scanning_configuration) and later disabled,
    this setting ensures repos fall back to Basic scans.  */
    scan_on_push = true
  }

  tags = each.value.tags
}

#---------------------------------------------------------------------

resource "aws_ecr_registry_scanning_configuration" "this" {
  scan_type = var.registry_scanning_config.scan_type

  dynamic "rule" {
    for_each = coalesce(var.registry_scanning_config.repo_scan_rules, {})

    content {
      scan_frequency = rule.value

      repository_filter {
        filter      = rule.key
        filter_type = "WILDCARD"
      }
    }
  }
}

#---------------------------------------------------------------------

resource "aws_ecr_registry_policy" "list" {
  count = var.registry_policy_json != null ? 1 : 0

  policy = var.registry_policy_json
}

# TODO Add aws_ecr_lifecycle_policy
# TODO Add aws_ecr_pull_through_cache_rule
# TODO Add aws_ecr_replication_configuration

######################################################################
