######################################################################
### AWS EventBridge Event Buses

resource "aws_cloudwatch_event_bus" "map" {
  for_each = var.event_buses

  name              = each.key
  event_source_name = each.value.event_source_name
  tags              = each.value.tags
}

resource "aws_cloudwatch_event_bus_policy" "map" {
  for_each = aws_cloudwatch_event_bus.map

  event_bus_name = aws_cloudwatch_event_bus.map[each.key].name
  policy         = data.aws_iam_policy_document.Event_Bus_Policies[each.key].json
}

# FIXME Below is for Org access. Great, but parameterize.

data "aws_iam_policy_document" "Event_Bus_Policies" {
  for_each = var.event_buses

  /* override_policy_documents is used here in lieu of source_policy_documents,
  because the source_ property requires each statement to have a unique Sid. */
  override_policy_documents = (
    each.value.event_bus_policy_json != null
    ? [each.value.event_bus_policy_json]
    : null
  )

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
