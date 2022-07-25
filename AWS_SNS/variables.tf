######################################################################
### INPUT VARIABLES

variable "sns_topics" {
  description = "Map of SNS Topic names to config objects."
  type = map(
    # map keys: SNS Topic names
    object({
      policy_json       = string
      display_name      = optional(string)
      kms_master_key_id = optional(string)
      delivery_policy   = optional(string)
      tags              = optional(map(string))
    })
  )
}

######################################################################
