######################################################################
### INPUT VARIABLES
#---------------------------------------------------------------------
### ECS Cluster Inputs

variable "ecs_cluster" {
  description = <<-EOF
  Config object for the ECS Cluster and its CloudWatch Logs log group. The
  "should_enable_container_insights" property defaults to "true". If a
  value for "cloudwatch_log_group.retention_in_days" is not provided, the
  default is 400 days. ECS Exec will be enabled if "ecs_exec_kms_key_alias"
  is provided; to ensure it's DISABLED, simply don't provide a value or set
  it to "null".
  EOF
  type = object({
    name                             = string
    capacity_provider_arns           = optional(list(string))
    should_enable_container_insights = optional(bool)
    ecs_exec_kms_key_alias           = optional(string)
    tags                             = optional(map(string))
    cloudwatch_log_group = object({
      name              = string
      kms_key_alias     = string
      retention_in_days = optional(number)
      tags              = optional(map(string))
    })
  })
}

#---------------------------------------------------------------------
### Default Capacity Provider Inputs

variable "default_capacity_provider" {
  description = "Config object for the cluster's default capacity provider."
  type = object({
    name = optional(string)
    tags = optional(map(string))
    autoscaling_group = optional(object({
      name = optional(string)
      tags = optional(map(string))
      launch_template = optional(object({
        name        = optional(string)
        description = optional(string)
        tags        = optional(map(string))
      }))
    }))
  })
  default = {
    name = "Default_CapacityProvider"
    tags = { Name = "Default_CapacityProvider" }
    autoscaling_group = {
      name = "Default_CapacityProvider_AutoScaling_Group"
      tags = { Name = "Default_CapacityProvider_AutoScaling_Group" }
      launch_template = {
        name        = "Default_CapacityProvider_LaunchTemplate"
        description = "Terraform-managed launch template for an ECS Cluster's default capacity provider."
        tags        = { Name = "Default_CapacityProvider_LaunchTemplate" }
      }
    }
  }
}

#---------------------------------------------------------------------
### Default Capacity Provider Inputs

variable "service_discovery_namespace" {
  description = "Config object for the \"aws_service_discovery_private_dns_namespace\" resource."
  type = object({
    name        = string
    description = string
    vpc_id      = string
    tags        = optional(map(string))
  })
}

######################################################################
