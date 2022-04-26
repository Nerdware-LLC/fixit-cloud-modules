######################################################################
### INPUT VARIABLES

variable "guardduty_admin_account_id" {
  description = <<-EOF
  The ID of the account designated as the delegated administrator for
  the GuardDuty service in all regions.
  EOF

  type = string
}

#---------------------------------------------------------------------

variable "finding_publishing_frequency" {
  description = <<-EOF
  How often the GuardDuty Detector should publish findings. Allowed
  values are "FIFTEEN_MINUTES", "ONE_HOUR", or "SIX_HOURS" (default).
  EOF

  type    = string
  default = "SIX_HOURS"

  validation {
    condition = contains(
      ["FIFTEEN_MINUTES", "ONE_HOUR", "SIX_HOURS"],
      var.finding_publishing_frequency
    )
    error_message = "Invalid publishing frequency value."
  }
}

#---------------------------------------------------------------------

variable "detector_tags" {
  description = "The tags of the GuardDuty Detector."
  type        = map(string)
  default     = null
}

######################################################################
