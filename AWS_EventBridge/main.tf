######################################################################
### AWS EventBridge
######################################################################
### Event Buses

resource "aws_cloudwatch_event_bus" "map" {
  for_each = var.event_buses

  name              = each.key
  event_source_name = each.value.event_source_name
  tags              = each.value.tags
}

#---------------------------------------------------------------------
### Event Bus Policies

resource "aws_cloudwatch_event_bus_policy" "map" {
  for_each = aws_cloudwatch_event_bus.map

  event_bus_name = aws_cloudwatch_event_bus.map[each.key].name
  policy         = data.aws_iam_policy_document.Event_Bus_Policies_Map[each.key].json
}

data "aws_iam_policy_document" "Event_Bus_Policies_Map" {
  for_each = var.event_buses

  /* override_policy_documents is used here in lieu of source_policy_documents,
  because the source_ property requires each statement to have a unique Sid. */
  override_policy_documents = each.value.event_bus_policy_json != null ? [each.value.event_bus_policy_json] : null

  dynamic "statement" {
    for_each = each.value.event_bus_policy_statements != null ? each.value.event_bus_policy_statements : []

    content {
      sid    = statement.value.sid
      effect = title(statement.value.effect)

      dynamic "principals" {
        for_each = (
          statement.value.principals != null
          ? statement.value.principals
          : {}
        )

        content {
          type        = principals.key # "AWS", "Service", or "Federated"
          identifiers = principals.value
        }
      }

      actions = statement.value.actions
      resources = (
        statement.value.resources == null
        ? null
        : [
          for resource in statement.value.resources : try(
            aws_cloudwatch_event_bus.map[resource].arn,    # <-- check if "resource" is an Event Bus name
            aws_cloudwatch_event_target.map[resource].arn, # <-- check if "resource" is an Event Target name
            aws_cloudwatch_event_rule.map[resource].arn,   # <-- check if "resource" is an Event Rule name
            resource                                       # <-- if none of the above, pass "resource" as-is
          )
        ]
      )

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
### Event Rules

resource "aws_cloudwatch_event_rule" "map" {
  for_each = var.event_rules

  name                = each.key
  description         = each.value.description
  role_arn            = each.value.role_arn
  schedule_expression = each.value.schedule_expression
  event_pattern       = each.value.event_pattern
  event_bus_name      = each.value.event_bus_name
  is_enabled          = coalesce(each.value.enabled, true)
  tags                = each.value.tags
}

#---------------------------------------------------------------------
### Event Targets

resource "aws_cloudwatch_event_target" "map" {
  for_each = var.event_targets

  target_id = each.key
  rule      = each.value.rule_name
  arn       = each.value.target_arn

  event_bus_name = each.value.event_bus_name
  role_arn       = each.value.role_arn
  retry_policy   = each.value.retry_policy

  input             = each.value.input
  input_path        = each.value.input_path
  input_transformer = each.value.input_transformer
}

######################################################################
