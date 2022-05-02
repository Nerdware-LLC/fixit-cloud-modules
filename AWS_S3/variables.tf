######################################################################
### INPUT VARIABLES
######################################################################
### S3 Bucket

variable "bucket_name" {
  description = <<-EOF
  The name of the S3 bucket. Warning: this value cannot be changed
  after bucket creation - changing this input will therefore force
  the creation of a new bucket. The list of bucket-naming rules is
  available at the link below.
  https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html.
  EOF

  type = string
}

variable "bucket_tags" {
  description = "The tags of the S3 bucket."
  type        = map(string)
  default     = null
}

#---------------------------------------------------------------------
### S3 Bucket Policy

variable "bucket_policy" {
  description = <<-EOF
  The IAM bucket policy of the S3 bucket. If not provided, a bucket policy
  will be created which enforces the use of SSE-related headers for all
  PutObject operations. If provided, the value must be a JSON-encoded string
  which can be properly converted into a valid bucket policy upon being passed
  into the "jsondecode" Terraform function. The aforementioned SSE-related
  headers will be merged into the resulting policy object.
  EOF

  type    = string
  default = null

  validation {
    condition     = var.bucket_policy == null || can(jsondecode(var.bucket_policy))
    error_message = "\"bucket_policy\" value must be a valid JSON-encoded string."
  }
}

#---------------------------------------------------------------------
### S3 Object Lock - Bucket Default Retention

variable "object_lock_default_retention" {
  description = <<-EOF
  Config object to set the bucket's default object-lock retention policy.
  The "mode" property can be either "COMPLIANCE" or "GOVERNANCE". For the
  retention period duration, supply a number to either "days" or "years",
  but not both.
  EOF

  type = object({
    mode  = string
    days  = optional(number)
    years = optional(number)
  })

  default = null

  validation {
    condition = anytrue([
      # If var is not provided, value will be null
      var.object_lock_default_retention == null,
      # Else if provided, the following must be all true
      alltrue([
        # "mode" must be valid
        contains(["COMPLIANCE", "GOVERNANCE"], var.object_lock_default_retention),
        # either "days" OR "years", but not both
        1 == length(distinct([
          var.object_lock_default_retention.days,
          var.object_lock_default_retention.years,
        ]))
      ])
    ])
    error_message = "Invalid 'object_lock_default_retention'."
  }
}

#---------------------------------------------------------------------
### S3 Bucket Server Side Encryption

variable "sse_kms_config" {
  description = <<-EOF
  Config object to utilize an existing KMS key for server-side encryption
  (SSE-by-default is enabled on all buckets created by this module). If not
  provided, the AWS-managed SSE-S3 key will be used instead. If a KMS key
  ARN is provided, it is highly recommended to permit the bucket to use
  the key as a Bucket-Key, thereby reducing KMS-related costs by more than
  90% on average. This is not enforced by default, however, since enabling
  the Bucket-Key feature may require refactoring of the KMS key policy (S3
  encryption context conditions for Bucket-Keys must point to the ARN of
  the BUCKET - not the ARN of OBJECTS, as is the case for non-Bucket-Key
  SSE-KMS keys). A KMS key alias may be provided in lieu of an ARN, but this
  is highly discouraged if the bucket may be used in cross-account operations,
  as the KMS service will resolve the key within the REQUESTER'S account,
  which can result in data encrypted with a KMS key that belongs to the
  requester, and not the bucket administrator. Please be aware that SSE-KMS
  may NOT be used for access-logs buckets.
  EOF

  type = object({
    key_arn                  = string
    should_enable_bucket_key = bool
  })
  default = null
}

#---------------------------------------------------------------------
### S3 MFA Delete

variable "mfa_delete_config" {
  description = <<-EOF
  Config object for the MFA-delete feature. If the bucket will instead
  enable the lifecycle-rule configs feature, simply exclude this variable.
  EOF

  type = object({
    auth_device_serial_number = string
    auth_device_code_value    = string
  })
  default = null
}

#---------------------------------------------------------------------
### S3 Bucket Lifecycle Config

variable "lifecycle_rules" {
  description = <<-EOF
  Map of lifecycle rule config objects. If the bucket must utilize the
  MFA-delete feature, simply exclude this variable. Each key should be
  the name of a lifecycle rule with a value set to an object with rule
  config properties. Please refer to the relevant resource docs (link
  below) in TF Registry for info regarding the available rule params:
  https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration#argument-reference.
  EOF

  type = map(object({
    # Use rule names for map keys
    filter = optional(object({
      prefix                   = optional(string)
      object_size_greater_than = optional(number) # Min size in bytes to which the rule applies.
      object_size_less_than    = optional(number) # Max size in bytes to which the rule applies.
      tag                      = optional(object({ key = string, value = string }))
      and = optional(object({
        prefix                   = optional(string)
        object_size_greater_than = optional(number)
        object_size_less_than    = optional(number)
        tags                     = optional(map(string))
      }))
    }))
    abort_incomplete_multipart_upload = optional(object({
      days_after_initiation = number
    }))
    transition = optional(object({
      date          = optional(string) # If provided, must be in RFC 3339 format.
      days          = optional(number) # If provided, must a non-zero positive integer.
      storage_class = string
    }))
    expiration = optional(object({
      date                         = optional(string)
      days                         = optional(number)
      expired_object_delete_marker = optional(bool)
    }))
    noncurrent_version_transition = optional(object({
      newer_noncurrent_versions = optional(number)
      noncurrent_days           = optional(number)
      storage_class             = string
    }))
    noncurrent_version_expiration = optional(object({
      newer_noncurrent_versions = optional(number)
      noncurrent_days           = optional(number)
    }))
    status = optional(string) # Defaults to "Enabled", can optionally pass "Disabled".
  }))
  default = null
}

#---------------------------------------------------------------------
### S3 Bucket Access Logging

variable "access_logs_config" {
  description = <<-EOF
  Config object for logging bucket access events. This variable should
  only be excluded if the bucket being created will itself be designated
  to receive access logs from other buckets (in which case, do not provide
  a value for var.sse_kms_config - access logs buckets must use SSE-S3).
  "bucket_name" must be the name of an existing S3 bucket to which to send
  access logs. By default, "access_logs_prefix" will be set to the
  var.bucket_name value.
  EOF

  type = object({
    bucket_name        = string
    access_logs_prefix = optional(string)
  })
  default = null
}

#---------------------------------------------------------------------
### S3 Bucket - Transfer Acceleration

variable "transfer_acceleration" {
  description = <<-EOF
  Set to "Enabled" to enable transfer acceleration. May also be set to
  "Suspended" after transfer acceleration has been enabled to temporarily
  turn off transfer acceleration.
  EOF

  type    = string
  default = null

  validation {
    condition     = contains([null, "Enabled", "Suspended"], var.transfer_acceleration)
    error_message = "Invalid 'transfer_acceleration' value."
  }
}

#---------------------------------------------------------------------
### S3 Bucket Replication Config

variable "replication_config" {
  description = <<-EOF
  Config object for replication of bucket objects. For the "rules" property, map each
  rule name to an object configuring the rule. Rule names must be less than or equal
  to 255 characters.

  Rule Properties: Each rule's "priority" should be a number unique among all provided
  rules; these numbers determine which rule's filter takes precedence, with higher
  numbers taking priority (if no rules contain filters, "priority" values have no effect).
  "is_enabled" defaults to "true" if not provided. The "should_replicate ..." properties
  all default to "true" if not provided.

  Destination Properties: In the "destination" config, "should_destination_become_owner"
  defaults to "true" if not provided. "should_enable_metrics" defaults to "false"; if
  metrics are enabled, the S3 service will send replication metrics to CloudWatch. If the
  destination bucket uses SSE-KMS, the ARN of the dest bucket's encryption key must be
  provided via the "replica_kms_key_arn" property. "should_replication_complete_within_15_minutes"
  defaults to "false"; when set to "true", the S3 service will create S3 Event Notifications
  if the replication process fails and/or takes longer than 15 minutes (the amount of time
  is not currently customizable). By default, if "storage_class" is not specified, the S3
  service uses the storage class of the source object to create the replica; valid override
  values are "STANDARD_IA", "INTELLIGENT_TIERING", "ONEZONE_IA", "GLACIER_IR", "GLACIER",
  and "DEEP_ARCHIVE".
  EOF

  type = object({
    s3_replication_service_role_arn = string
    rules = map(object({
      priority                           = number
      is_enabled                         = optional(bool)
      should_replicate_delete_markers    = optional(bool)
      should_replicate_existing_objects  = optional(bool)
      should_replicate_encrypted_objects = optional(bool)
      filter = optional(object({
        prefix = optional(string)
        tag    = optional(object({ key = string, value = string }))
        and = optional(object({
          prefix = optional(string)
          tags   = optional(map(string))
        }))
      }))
      destination = object({
        account                                       = optional(string)
        bucket_arn                                    = string
        storage_class                                 = optional(string)
        replica_kms_key_arn                           = optional(string) # dest bucket SSE-KMS key ARN
        should_destination_become_owner               = optional(bool)
        should_enable_metrics                         = optional(bool)
        should_replication_complete_within_15_minutes = optional(bool)
      })
    }))
  })

  default = null
}

#---------------------------------------------------------------------
### S3 Web Host

variable "web_host_config" {
  description = <<-EOF
  Config object for setting up the bucket as a web host. Either "routing" OR
  "redirect_all_requests_to" must be specified, but not both. The property
  "routing.redirect_rules", if provided, must map names of routing-rules to
  objects which define them. The "replace" property may use either "key_with"
  OR "key_prefix_with", but not both. The two "protocol" properties can be
  either "http" or "https"; if not provided (null) the default behavior will
  be to use the protocol used in the original request.
  EOF

  type = object({
    routing = optional(object({
      index_document = string
      error_document = optional(string)
      redirect_rules = optional(map(object({
        host_name          = optional(string) # The host name to use in the redirect request
        protocol           = optional(string) # http / https / null
        http_redirect_code = optional(string) # The HTTP redirect code to use on the response
        replace = optional(object({
          key_prefix_with = optional(string) # docs/ --> documents/
          key_with        = optional(string) # foo.html --> error.html
        }))
        condition = optional(object({
          http_error_code_returned_equals = optional(string) # "404"
          key_prefix_equals               = optional(string) # docs/
        }))
      })))
    }))
    redirect_all_requests_to = optional(object({
      host_name = string
      protocol  = optional(string) # http / https / null
    }))
  })

  default = null

  validation {
    condition = ( # web_host_config --> OK if null, else alltrue conditions.
      var.web_host_config == null || alltrue([
        # Either "routing" OR "redirect_all_requests_to", but not both.
        1 == length(keys(var.web_host_config)),
        # redirect_rules --> OK if null, else alltrue conditions.
        var.web_host_config.redirect_rules == null || alltrue(flatten([
          # Note: a splat won't work here, bc the parent obj may not exist.
          for rule_obj in values(var.web_host_config.redirect_rules) : (
            # replace --> OK if null, else either "key_with" OR "key_prefix_with" but not both.
            rule_obj.replace == null || 1 == length(keys(rule_obj.replace))
          )
        ]))
      ])
    )
    error_message = "Invalid combination of properties on 'web_host_config'."
  }
}

#---------------------------------------------------------------------
### S3 CORS Config

variable "cors_rules" {
  description = <<-EOF
  Config map for CORS rules; map rule IDs/names to objects which define
  them. The map keys (rule IDs/names) cannot be longer than 255 characters.
  For "allowed_methods", valid values are GET, PUT, HEAD, POST, and DELETE.
  HTTP headers included in "allowed_headers" will be specified in the
  "Access-Control-Request-Headers" header. "max_age_seconds" sets the time
  in seconds that a browser is to cache the preflight response for the
  specified resource.
  EOF

  type = map(object({
    allowed_methods = list(string)
    allowed_origins = list(string)
    allowed_headers = optional(list(string))
    expose_headers  = optional(list(string))
    max_age_seconds = number
  }))

  default = null
}

######################################################################
