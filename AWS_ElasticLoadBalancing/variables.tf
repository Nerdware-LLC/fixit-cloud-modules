######################################################################
### INPUT VARIABLES

variable "load_balancers" {
  description = <<-EOF
  Map of load balancer names to config objects.
  "type" must be either "application", "network", or "gateway".
  "is_internal" and "is_dualstack" both default to false if not provided.
  "alb_should_enable_http2" defaults to true, and is only applicable to Application LBs.
  "nlb_enable_cross_zone_load_balancing" defaults to false, and is only applicable to Network LBs.
  "enable_deletion_protection" defaults to true.
  "desync_mitigation_mode" can be one of "monitor", "strictest", or "defensive" (default).
  "idle_timeout_seconds" defaults to 60.
  EOF

  type = map(
    # map keys: load balancer names
    object({
      type         = string
      is_internal  = optional(bool) # default: false
      is_dualstack = optional(bool) # default: false
      subnets = optional(map(
        # map keys: subnet names
        object({
          subnet_id                = string
          elastic_ip_allocation_id = optional(string)
          private_ipv4_address     = optional(string)
          ipv6_address             = optional(string)
        })
      ))
      alb_security_group_ids               = optional(list(string))
      alb_should_enable_http2              = optional(bool) # default: true
      nlb_enable_cross_zone_load_balancing = optional(bool)
      enable_deletion_protection           = optional(bool)   # default: true
      desync_mitigation_mode               = optional(string) # default: "defensive"
      idle_timeout_seconds                 = optional(number)
      access_logging = optional(object({
        s3_bucket_name = string
        log_prefix     = optional(string)
        is_enabled     = optional(bool) # default: true
      }))
      tags = optional(map(string))

      # TODO var.listeners, or "listeners" here
    })
  )
}

#---------------------------------------------------------------------

# variable "listeners" {
#   type = map
# }

######################################################################
