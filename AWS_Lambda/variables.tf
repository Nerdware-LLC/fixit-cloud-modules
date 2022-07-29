######################################################################
### INPUT VARIABLES

variable "name" {
  description = "The Lambda function name."
  type        = string
}

variable "description" {
  description = "(Optional) The Lambda function description."
  type        = string
  default     = null
}

variable "execution_role_arn" {
  description = "The IAM Role ARN for the function's execution role."
  type        = string
}

variable "vpc_config" {
  description = "(Optional) VPC configs for the Lambda function."
  type = object({
    security_group_ids = list(string)
    subnet_ids         = list(string)
  })
  default = null
}

variable "runtime" {
  description = <<-EOF
  (Optional) The Lambda function runtime; see link below for valid runtime values.
  https://docs.aws.amazon.com/lambda/latest/dg/API_CreateFunction.html#SSS-CreateFunction-request-Runtime
  EOF

  type    = string
  default = null
}

variable "handler" {
  description = "The Lambda function handler."
  type        = string
  default     = "index.handler"
}

variable "deployment_package_src" {
  description = <<-EOF
  The Lambda deployment package source; must be either an absolute path
  to an executable on the local filesystem, an image URI, or an object
  configuring retrieval from an S3 bucket.
  EOF

  type = object({
    local_file_abs_path = optional(string)
    image_uri           = optional(string)
    s3_bucket = optional(object({
      bucket_name    = string
      object_key     = string
      object_version = string
    }))
  })

  # Ensure one of the top-level keys has been provided
  validation {
    condition     = 1 == length(keys(var.deployment_package_src))
    error_message = "Only 1 key-value pair can be provided to configure the deployment package source."
  }
}

variable "environment_variables" {
  description = "(Optional) Map of env vars to make accessible to the function during execution."
  type        = map(string)
  default     = null
}

variable "dead_letter_target_arn" {
  description = <<-EOF
  (Optional) ARN of SNS Topic or SQS Queue to notify when a function invocation
  fails. If this option is used, the function's IAM role must be granted suitable
  access to write to the target object, which means allowing either the sns:Publish
  or sqs:SendMessage action on this ARN, depending on which service is targeted.
  EOF

  type    = string
  default = null
}

variable "tags" {
  description = "(Optional) The Lambda function tags."
  type        = map(string)
  default     = null
}

######################################################################
