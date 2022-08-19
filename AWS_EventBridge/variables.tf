######################################################################
### INPUT VARIABLES

variable "event_rules" {
  description = "(Optional) Map of EventBridge rule names to config objects."
  type = map(
    # map keys: event rule names
    object({
      is_enabled          = optional(bool)
      description         = optional(string)
      role_arn            = optional(string)
      schedule_expression = optional(string)
      event_pattern       = optional(string)
      event_bus_name      = optional(string)
      tags                = optional(map(string))
    })
  )
  default = {}
}

#---------------------------------------------------------------------

variable "event_targets" {
  description = ""
  type = map(
    # map keys: event target IDs
    object({
      target_arn     = string
      rule_name      = string
      event_bus_name = optional(string)
      input          = optional(string)
      input_path     = optional(string)
      role_arn       = optional(string)
      retry_policy   = optional(string)
      # TODO finish this resource
    })
  )
}

#---------------------------------------------------------------------

variable "event_buses" {
  description = <<-EOF
  (Optional) Map of EventBridge Event Bus names to config objects.
  // TODO write more here
  EOF

  type = map(
    # map keys: Event Bus names
    object({
      event_source_name     = optional(string)
      tags                  = optional(map(string))
      event_bus_policy_json = optional(string)
      event_bus_policy_statements = optional(list(object({
        sid    = optional(string)
        effect = string
        principals = optional(map(
          # map keys: "AWS", "Service", and/or "Federated"
          list(string)
        ))
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
    })
  )
}

######################################################################
