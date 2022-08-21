######################################################################
### OUTPUTS

output "Lambda_Function" {
  description = "The Lambda function resource object."
  value       = aws_lambda_function.this
}

output "Lambda_Function_Provisioned_Concurrency_Config" {
  description = "The Lambda function provisoined concurrency config resource object."
  value       = aws_lambda_provisioned_concurrency_config.this
}

output "Lambda_Function_ExecutionRole" {
  description = "The Lambda function execution role resource object."
  value       = aws_iam_role.Lambda_ExecRole
}

output "Lambda_Function_Permissions" {
  description = "Map of Lambda function permission resource objects."
  value       = aws_lambda_permission.map
}

output "Lambda_Event_Source_Mappings" {
  description = "Map of Lambda event source mapping resource objects."
  value       = aws_lambda_event_source_mapping.map
}

######################################################################
