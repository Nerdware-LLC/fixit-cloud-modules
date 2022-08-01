######################################################################
### INPUT VARIABLES

variable "key_description" {
  description = "A description of the KMS key and/or its purpose."
  type        = string
  default     = null
}

#---------------------------------------------------------------------

variable "key_policy" {
  description = "A JSON-encoded KMS key policy."
  type        = string

  validation {
    condition     = can(jsondecode(var.key_policy))
    error_message = "\"key_policy\" value must be a valid JSON-encoded string."
  }
}

#---------------------------------------------------------------------

variable "is_multi_region_key" {
  description = <<-EOF
  Boolean indicating whether the key is a multi-region key; defaults to
  false if not provided.
  EOF

  type    = bool
  default = false
}

#---------------------------------------------------------------------

variable "should_enable_key_rotation" {
  description = <<-EOF
  Boolean indicating whether the key has the auto-rotation feature enabled;
  defaults to true if not provided.
  EOF

  type    = bool
  default = true
}

#---------------------------------------------------------------------

variable "key_tags" {
  description = "Map of tags to apply to the KMS key."
  type        = map(any)
  default     = null
}

#---------------------------------------------------------------------

variable "key_alias" {
  description = "An alias to apply to the KMS key."
  type        = string
  default     = null
}

#---------------------------------------------------------------------

variable "regional_replicas" {
  description = "Map of regions in which to replicate the KMS key; each region defaults to \"false\"."

  type = object({
    ap-northeast-1 = optional(bool) # Asia Pacific (Tokyo)
    ap-northeast-2 = optional(bool) # Asia Pacific (Seoul)
    ap-northeast-3 = optional(bool) # Asia Pacific (Osaka)
    ap-south-1     = optional(bool) # Asia Pacific (Mumbai)
    ap-southeast-1 = optional(bool) # Asia Pacific (Singapore)
    ap-southeast-2 = optional(bool) # Asia Pacific (Sydney)
    ca-central-1   = optional(bool) # Canada (Central)
    eu-north-1     = optional(bool) # Europe (Stockholm)
    eu-central-1   = optional(bool) # Europe (Frankfurt)
    eu-west-1      = optional(bool) # Europe (Ireland)
    eu-west-2      = optional(bool) # Europe (London)
    eu-west-3      = optional(bool) # Europe (Paris)
    sa-east-1      = optional(bool) # South America (São Paulo)
    us-east-1      = optional(bool) # US East (N. Virginia)
    us-west-1      = optional(bool) # US West (N. California)
    us-west-2      = optional(bool) # US West (Oregon)
  })

  default = {}
}

######################################################################
