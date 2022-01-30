######################################################################
### INPUT VARIABLES

variable "name" {
  description = "Name of the Instance Profile."
  type        = string
}

variable "path" {
  description = "Path to the instance profile; defaults to \"/\"."
  type        = string
  default     = null
}

variable "tags" {
  description = "Map of resource tags for the IAM Instance Profile."
  type        = string
  default     = null
}

variable "iam_role" {
  description = <<-EOF
  Config object for the Instance Profile's associated IAM Role. Existing
  IAM policies can be attached via the "policy_arns" key; alternatively,
  policies unique to this Instance Profile resource can be provided via
  the "custom_iam_policies" key. Either way, all policies are attached
  via the "aws_iam_role_policy_attachment" resource.
  EOF
  type = object({
    name        = string
    description = optional(string)
    path        = optional(string)
    tags        = optional(map(string))
    policy_arns = optional(list(string))
    custom_iam_policies = optional(list(object({
      policy_name = string
      policy_json = string
      description = optional(string)
      path        = optional(string)
      tags        = optional(map(string))
    })))
  })
}

######################################################################
