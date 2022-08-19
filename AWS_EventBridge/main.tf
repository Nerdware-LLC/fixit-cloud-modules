######################################################################
### AWS EventBridge

resource "aws_cloudwatch_event_rule" "map" {
  for_each = var.event_rules

  name                = each.key
  description         = each.value.description
  role_arn            = each.value.role_arn
  schedule_expression = each.value.schedule_expression
  event_pattern       = each.value.event_pattern
  event_bus_name      = each.value.event_bus_name
  is_enabled          = coalesce(each.value.is_enabled, true)
  tags                = each.value.tags
}

#---------------------------------------------------------------------

resource "aws_cloudwatch_event_target" "map" {
  for_each = var.event_targets

  target_id = each.key
  arn       = each.value.target_arn
  rule      = each.value.rule_name

  run_command_targets {
    key    = "tag:Name"
    values = ["FooBar"]
  }

  run_command_targets {
    key    = "InstanceIds"
    values = ["i-162058cd308bffec2"]
  }
}

#---------------------------------------------------------------------


######################################################################
