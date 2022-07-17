######################################################################
### INPUT VARIABLES

variable "config_aggregator" {
  description = "(Optional) Config object for the AWS-Config Aggregator resource."

  type = object({
    name                 = string
    iam_service_role_arn = string
    tags                 = optional(map(string))
  })

  default = null
}

variable "config_recorders" {
  description = <<-EOF
  Config object for AWS-Config Recorder resources; one Config Recorder
  is created in each region.
  EOF

  type = object({
    name     = string
    role_arn = string
  })
}

variable "config_sns_topics" {
  description = <<-EOF
  Config object for Config-related SNS Topic resources; one SNS Topic
  is created in each region. For this reason, the kms_master_key_id value,
  if provided, must point to a multi-region key at this time.
  EOF

  type = object({
    name              = string
    display_name      = optional(string)
    kms_master_key_id = optional(string)
    tags              = optional(map(string))
  })
}

variable "config_delivery_channels" {
  description = <<-EOF
  Config object for AWS-Config Delivery Channel resources; one Delivery
  Channel is created in each region. Allowed values for "snapshot_frequency"
  are "One_Hour", "Three_Hours", "Six_Hours", "Twelve_Hours", or
  "TwentyFour_Hours" (default).
  EOF

  type = object({
    name               = string
    snapshot_frequency = optional(string)
    s3_bucket = object({
      name            = string
      key_prefix      = optional(string)
      sse_kms_key_arn = optional(string)
    })
  })
}

######################################################################
