######################################################################
### INPUT VARIABLES

variable "table_name" {
  description = "The name of the DynamoDB table."
  type        = string
}

variable "hash_key" {
  description = "The DynamoDB table's hash key (also called a \"partition\" or \"primary\" key)."
  type        = string
}

variable "range_key" {
  description = "(Optional) The DynamoDB table's range key (also called a \"sort\" key)."
  type        = string
  default     = null
}

variable "attributes" {
  description = <<-EOF
  List of DynamoDB table attribute config objects. Attribute "type" values
  must be either "S", "N", or "B" (for String, Number, or Binary). All table
  and index keys must be defined here, along with any attributes included in
  index "non_key_attributes" lists.
  EOF

  type = list(object({
    name = string
    type = string # "S", "N", or "B"
  }))
}

variable "global_secondary_indexes" {
  description = <<-EOF
  (Optional) Map of GSI names to config objects for each respective GSI. Note
  that the maximum number of GSIs a DynamoDB table can have is 20. Each GSI must
  have a "hash_key", and can optionally define a "range_key", both of which must
  be included in var.attributes. "projection_type" defines which table attributes
  to include (or "project") in the index - it must be either "KEYS_ONLY", "ALL",
  or "INCLUDE". "KEYS_ONLY" will result in just the table's hash_key and range_key
  being included in the index, "ALL" will result in every table attribute being
  included in the index, and "INCLUDE" will result in the table's hash_key,
  range_key, and attributes defined in the "non_key_attributes" list being included
  in the index. Note that any attributes listed in "non_key_attributes" must be
  defined in var.attributes. If the base table uses "PROVISIONED" throughput, all
  GSI configs must specify autoscaling configs via the "capacity" property with
  "min", "max", and "target_percentage" values for both "read" and "write".
  "target_percentage" reflects the desired utilization of provisioned capacity.
  EOF

  type = map(
    # map keys: GSI names
    object({
      hash_key           = string
      range_key          = optional(string)
      projection_type    = string
      non_key_attributes = optional(list(string))
      capacity = optional(object({
        read = object({
          max               = number
          target_percentage = number
          min               = number
        })
        write = object({
          max               = number
          target_percentage = number
          min               = number
        })
      }))
    })
  )
  default = {}
}

variable "local_secondary_indexes" {
  description = <<-EOF
  (Optional) Map of LSI names to config objects for each respective LSI. Note
  that the maximum number of LSIs a DynamoDB table can have is 5. All LSIs use
  the table's "hash_key" as their own, and must define a "range_key".
  EOF

  type = map(
    # map keys: LSI names
    object({
      range_key          = string
      projection_type    = string
      non_key_attributes = optional(list(string))
    })
  )
  default = {}
}

variable "server_side_encryption" {
  description = <<-EOF
  Config object for the DynamoDB table's server side encryption. "key_type" must
  be either "AWS-OWNED", "AWS-MANAGED", or "CMK" (customer-managed key). For "CMK",
  a "kms_key_arn" must be provided (this can also be an alias). For more information,
  see [DynamoDB Server-Side Encryption](#dynamodb-server-side-encryption).
  EOF

  type = object({
    key_type    = string
    kms_key_arn = optional(string)
  })

  validation {
    condition = anytrue([
      # If kms_key_arn is null, key_type must be AWS-OWNED or AWS-MANAGED.
      contains(["AWS-OWNED", "AWS-MANAGED"], var.server_side_encryption.key_type)
      && lookup(var.server_side_encryption, "kms_key_arn", null) == null,
      # If kms_key_arn is not null, key_type must be CMK.
      var.server_side_encryption.key_type == "CMK"
      && lookup(var.server_side_encryption, "kms_key_arn", null) != null
    ])
    error_message = "A KMS key ARN is required to use a CMK for table SSE."
  }
}

variable "billing_mode" {
  description = <<-EOF
  (Optional) The DynamoDB table's billing mode. This can either be "PROVISIONED"
  or "PAY_PER_REQUEST"; if no value is provided, this defaults to "PROVISIONED".
  A table with "PROVISIONED" billing must define a "capacity" config; see the
  var.capacity description for more information.
  EOF

  type    = string
  default = "PROVISIONED"
}

variable "capacity" {
  description = <<-EOF
  (Optional if var.billing_mode is PAY_PER_REQUEST) Autoscaling configs for a
  DynamoDB table with "PROVISIONED" throughput. "var.capacity" must specify "min",
  "max", and "target_percentage" values for both "read" and "write".
  "target_percentage" reflects the desired utilization of provisioned capacity.
  EOF

  type = object({
    read = object({
      max               = number
      target_percentage = number
      min               = number
    })
    write = object({
      max               = number
      target_percentage = number
      min               = number
    })
  })
  default = null
}

variable "table_storage_class" {
  description = <<-EOF
  (Optional) The storage class for the DynamoDB table. Can be either "STANDARD"
  or "STANDARD_INFREQUENT_ACCESS"; default: "STANDARD".
  EOF

  type    = string
  default = "STANDARD"
}

variable "ttl" {
  description = <<-EOF
  (Optional) Object for configuring TTL; "enabled" defaults to true if not provided.
  EOF

  type = object({
    enabled        = optional(bool)
    attribute_name = string
  })
  default = null
}

variable "enable_point_in_time_recovery" {
  description = <<-EOF
  (Optional) Point in time recovery is enabled by default; set to false to
  override this behavior.
  EOF

  type    = bool
  default = true
}

variable "restore_table_from" {
  description = <<-EOF
  (Optional) Use this variable to create a restore-table from a source table
  with point-in-time recovery enabled. To create a restore-table, you must
  provide a "source_table_name", and a time indicator. The time indicator
  can be specified using either "use_latest_recovery_point" (default: false),
  of an explicit date-time string can be supplied to "restore_date_time".
  Please see the README and AWS docs for more info on the necessary inputs.
  EOF

  type = object({
    source_table_name         = string
    use_latest_recovery_point = optional(bool)
    restore_date_time         = optional(string)
  })
  default = null
}

variable "streams" {
  description = <<-EOF
  (Optional) Object for enabling a DynamoDB table stream and/or a Kinesis
  data stream.

  For a DynamoDB table stream, "dynamodb_stream_view_type" must be one of
  "KEYS_ONLY", "NEW_IMAGE", "OLD_IMAGE", or "NEW_AND_OLD_IMAGES", which
  defines what table-modification info is added to each stream window. With
  "KEYS_ONLY", only the key attributes of the modified item are added; with
  "NEW_IMAGE", the entire item is added as it appears AFTER it was modified;
  with "OLD_IMAGE", the entire item is added as it appeared BEFORE it was
  modified; with "NEW_AND_OLD_IMAGES", both the new and old images are added
  to each stream window.

  For a Kinesis data stream, this module will associate a DynamoDB table with
  an existing Kinesis stream using the value provided to "kinesis_stream_arn",
  but does not create any Kinesis resources.
  EOF

  type = object({
    dynamodb_stream_view_type = optional(string)
    kinesis_stream_arn        = optional(string)
  })
  default = null
}

variable "replicas" {
  description = <<-EOF
  (Optional) Map for configuring table replicas. For map keys, use AWS region
  names for regions in which a replica table is desired; map region names to
  regional replica config objects. A "kms_key_arn" must be provided for each
  replica; this can be an alias given the proper key/alias/permissions configs.
  If not provided, "enable_point_in_time_recovery" defaults to true.
  EOF

  type = map(
    # map keys: AWS regions in which to create table replicas
    object({
      propagate_tags                = bool
      kms_key_arn                   = string
      enable_point_in_time_recovery = optional(bool) # default: false, make TRUE DEFAULT
    })
  )
  default = null
}

variable "tags" {
  description = "(Optional) Map of tags for the DynamoDB table."
  type        = map(string)
  default     = null
}

#---------------------------------------------------------------------
### DynamoDB Table Items

variable "dynamodb_table_items" {
  description = "(Optional) A list of JSON-encoded DynamoDB table items."
  type        = list(string)
  default     = null
}

######################################################################
