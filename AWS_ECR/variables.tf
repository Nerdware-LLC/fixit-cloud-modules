######################################################################
### INPUT VARIABLES

variable "repositories" {
  description = <<-EOF
  Map of ECR Repository names to config objects. For more fine-grained control
  over a repo's SSE, an AWS KMS key can be provided - otherwise the ECR default
  AES256 encryption will be used instead. "should_image_tags_be_immutabile"
  defaults to false if not provided.
  Use any of the provided "policy_config" properties to set commonly-used sets of
  permissions; for example, principals you provide in "allow_push_and_pull_images"
  will be granted all the necessary Allow-permissions necessary to push and pull
  images to and from the repo. Alternatively/additionally, any valid IAM policy
  state can be provided as a JSON array in "custom_statements_json", and the
  provided statements will be merged into any others you've configured.
  EOF
  type = map(
    # map keys: ECR repo names
    object({
      should_image_tags_be_immutabile = optional(bool)
      sse_config = optional(object({
        type        = string
        kms_key_arn = optional(string)
      }))
      tags = optional(map(string))
      policy_config = object({
        allow_push_and_pull_images = optional(object({
          principals = object({
            type        = string
            identifiers = list(string)
          })
          conditions = optional(map(
            # map keys: IAM condition operators (e.g., "StringEquals", "ArnLike")
            object({
              key    = string
              values = list(string)
            })
          ))
        }))
        allow_codebuild_access = optional(object({
          codebuild_project_source_arns = list(string)
          codebuild_account_ids         = list(string)
          custom_conditions = optional(map(
            # map keys: IAM condition operators (e.g., "StringEquals", "ArnLike")
            object({
              key    = string
              values = list(string)
            })
          ))
        }))
        custom_statements_json = optional(string)
      })
    })
  )
}

#---------------------------------------------------------------------

variable "registry_scanning_config" {
  description = <<-EOF
  (Optional) Config object for Enhanced image scanning. By default, all
  repos will be configured with Basic scanning. If "scan_type" is set to
  "ENHANCED", you can provide a map of "repo_scan_rules", in which regex
  strings can be supplied as keys to target one or more repos with a
  scan-frequency setting, which can be one of "MANUAL", "SCAN_ON_PUSH",
  or "CONTINUOUS_SCAN".
  EOF

  type = object({
    scan_type       = string
    repo_scan_rules = optional(map(string))
  })

  default = {
    scan_type       = "BASIC"
    repo_scan_rules = null
  }

  # Ensure all "repo_scan_rules" values, if any, are one of SCAN_ON_PUSH, CONTINUOUS_SCAN, or MANUAL.
  validation {
    condition = alltrue([
      for scan_frequency in values(try(coalesce(var.registry_scanning_config.repo_scan_rules, {}), {}))
      : contains(["SCAN_ON_PUSH", "CONTINUOUS_SCAN", "MANUAL"], scan_frequency)
    ])
    error_message = "All \"repo_scan_rules\" values must be one of \"SCAN_ON_PUSH\", \"CONTINUOUS_SCAN\", or \"MANUAL\"."
  }
}

#---------------------------------------------------------------------

variable "registry_policy_json" {
  description = <<-EOF
  (Optional) A JSON-encoded ECR Registry Policy. Registry policies set permissions
  at the registry level for "ecr:ReplicateImage", "ecr:BatchImportUpstreamImage",
  and "ecr:CreateRepository".
  EOF

  type    = string
  default = null
}

######################################################################
