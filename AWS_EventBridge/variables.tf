######################################################################
### INPUT VARIABLES

variable "event_rules" {
  description = "(Optional) Map of EventBridge rule names to config objects."
  type = map(
    # map keys: event rule names
    object({
      enabled             = optional(bool)
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
  description = <<-EOF
  (Optional) Map of EventBridge event target IDs to config objects. Target event
  input can be configured with either "input", "input_path", or "input_transformer".
  EOF

  type = map(
    # map keys: event target IDs
    object({
      target_arn        = string
      rule_name         = string
      event_bus_name    = optional(string)
      input             = optional(string)
      input_path        = optional(string)
      input_transformer = optional(string)
      role_arn          = optional(string)
      retry_policy      = optional(string)
    })
  )
  # Add target config inputs for ECS, run-command, kinesis
}

#---------------------------------------------------------------------

variable "event_buses" {
  description = <<-EOF
  (Optional) Map of EventBridge Event Bus names to config objects. To configure an
  event bus policy, you can either provide a JSON-encoded string to "event_bus_policy_json",
  or a list of policy statements to "event_bus_policy_statements".
  Within policy statements, to include the ARNs of event resources which are created within
  the same module call in your "resources" list(s), provide the event bus/target/rule NAME in
  "resources" and the name will be replaced by the ARN in the final policy document. Note that
  using this feature requires unique resource names; i.e., having an event BUS and event RULE
  with the same name would result in an error.
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
