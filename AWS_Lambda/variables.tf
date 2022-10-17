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

variable "handler" {
  description = "The Lambda function handler."
  type        = string
  default     = "index.handler"
}

variable "runtime" {
  description = <<-EOF
  (Optional) The Lambda function runtime; see link below for valid runtime values.
  https://docs.aws.amazon.com/lambda/latest/dg/API_CreateFunction.html#SSS-CreateFunction-request-Runtime
  EOF

  type    = string
  default = null
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
}

variable "execution_role" {
  description = "Config object for the Lambda function's execution role."
  type = object({
    name               = string
    description        = optional(string)
    path               = optional(string)
    tags               = optional(map(string))
    attach_policy_arns = optional(list(string))
    attach_policies = optional(map(
      # map keys: IAM policy names/IDs
      object({
        policy_json = optional(string)
        statements = optional(list(object({
          sid       = optional(string)
          effect    = string
          actions   = list(string)
          resources = optional(list(string))
          conditions = optional(map(
            # map keys: IAM condition operators (e.g., "StringEquals", "ArnLike")
            object({
              key    = string
              values = list(string)
            })
          ))
        })))
        description = optional(string)
        path        = optional(string)
        tags        = optional(map(string))
      })
    ))
  })
}

variable "vpc_config" {
  description = "(Optional) VPC configs for the Lambda function."
  type = object({
    security_group_ids = list(string)
    subnet_ids         = list(string)
  })
  default = null
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

variable "provisioned_concurrent_executions" {
  description = "(Optional) Amount of capacity to allocate. Must be greater than or equal to 1 (default 1)."
  type        = number
  default     = 1
}

variable "event_source_mapping" {
  description = <<-EOF
  (Optional) Config object to setup an event source mapping for the Lambda function.
  This allows Lambda functions to get events from Kinesis, DynamoDB, SQS, Amazon MQ
  and Managed Streaming for Apache Kafka (MSK). Reference documentation for these
  arguments is available [here][var-ref-event-src-mapping].
  EOF

  type = object({
    enabled                            = optional(bool)
    event_source_arn                   = optional(string)
    filter_patterns                    = optional(list(string))
    starting_position                  = optional(string)
    starting_position_timestamp        = optional(string) # RFC3339 timestamp
    queues                             = optional(string)
    batch_size                         = optional(number)
    maximum_batching_window_in_seconds = optional(number)
    maximum_record_age_in_seconds      = optional(number)
    maximum_retry_attempts             = optional(number)
    destination_config = optional(object({
      on_success_dest_resource_arn = string # TODO this is not being used
      on_failure_dest_resource_arn = optional(string)
    }))
  })

  default = null
}

variable "lambda_permissions" {
  description = <<-EOF
  (Optional) Map of principal names to Lambda permission config objects. Gives an
  external source (like an EventBridge Rule, SNS, or S3) permission to access the
  Lambda function. The principals can be AWS services, like "events.amazonaws.com",
  or AWS account IDs - any external principal that requires permission to invoke
  the Lambda function. With "qualifier" you can optionally narrow the permission to
  just a specific version or function alias. To ensure the permissions granted are
  not too broad, AWS service principals must be provided with a "source_arn"; for
  example, if the principal is EventBridge (events.amazonaws.com), the "source_arn"
  would be that of the EventBridge Rule. "principal_org_id" can be used to provide
  permissions to all accounts within an Organization.
  EOF

  type = map(
    # map keys: principal names ("events.amazonaws.com", account IDs, etc.)
    object({
      action           = string # e.g., "lambda:InvokeFunction"
      statement_id     = optional(string)
      qualifier        = optional(string) # option to specify a version or alias
      source_account   = optional(string)
      source_arn       = optional(string) # Required if principal is an AWS service
      principal_org_id = optional(string) # Principal would be the Org root account
    })
  )

  default = {}

  # Ensure perms for AWS service principals are narrowed to a specific "source_arn"
  validation {
    condition = alltrue([
      for principal, perm in var.lambda_permissions : (
        # principal is NOT an AWS service, OR has "source_arn"
        !can(regex(".amazonaws.com$", principal)) || lookup(perm, "source_arn", null) != null
      )
    ])
    error_message = "All AWS service Lambda permissions must provide a \"source_arn\" value."
  }
}

######################################################################
