######################################################################
### OUTPUTS

output "CloudTrail_Trail" {
  description = "The CloudTrail trail resource object."
  value       = aws_cloudtrail.this
}

######################################################################
