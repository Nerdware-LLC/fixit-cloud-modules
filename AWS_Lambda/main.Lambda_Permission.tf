######################################################################
### AWS Lambda - Permission (for external services like EventBridge)

resource "aws_lambda_permission" "map" {
  for_each = var.lambda_permissions

  principal        = each.key
  statement_id     = each.value.statement_id
  action           = each.value.action
  function_name    = aws_lambda_function.this.function_name
  qualifier        = each.value.qualifier
  source_account   = each.value.source_account
  source_arn       = each.value.source_arn
  principal_org_id = each.value.principal_org_id
}

######################################################################
