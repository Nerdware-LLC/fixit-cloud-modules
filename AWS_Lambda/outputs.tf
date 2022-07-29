######################################################################
### OUTPUTS

output "Lambda_Function" {
  description = "The Lambda function resource object."
  value       = aws_lambda_function.this
}

######################################################################
