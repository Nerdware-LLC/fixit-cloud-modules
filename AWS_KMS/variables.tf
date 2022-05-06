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

######################################################################
