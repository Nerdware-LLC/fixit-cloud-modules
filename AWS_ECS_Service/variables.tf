######################################################################
### INPUT VARIABLES
######################################################################
### ECS Service

variable "ecs_service" {
  description = "Config object for the ECS Service resource."
  type = object({
    name            = string
    ecs_cluster_arn = string
    instance_count = object({
      min     = number
      desired = number
      max     = number
    })
    enable_ecs_exec = optional(bool)
    tags            = optional(map(string))
  })
}

#---------------------------------------------------------------------
### ECS Service - Rolling Updates

variable "rolling_update_controls" {
  description = <<-EOF
  (Optional) Config object for rolling updates. Set "force_new_deployment"
  to "true" after the AMI pipeline updates the service image. Min/Max
  default to 100/200, respectively.
  EOF

  type = object({
    force_new_deployment               = bool
    deployment_minimum_healthy_percent = optional(number)
    deployment_maximum_percent         = optional(number)
  })

  default = null
}

#---------------------------------------------------------------------
### Network Inputs

variable "network_params" {
  description = <<-EOF
  Config object containing network parameters. The "assign_public_ip" bool
  switch is used to determine the networking mode in the Task Definition as well
  as the network configuration for the ECS Service. Since the "awsvpc" net mode
  can only be used in private subnets, a value of "true" will create a Task Def
  with the "bridge" network mode ("host" is not supported), and consequently the
  ECS Service will not have a network configuration. "subnet_ids" is a list of
  subnet IDs used by the "aws_ecs_service" and "aws_autoscaling_group" resources.
  EOF

  type = object({
    assign_public_ip   = bool
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
}

#---------------------------------------------------------------------
### Launch Template Inputs

variable "task_host_launch_template" {
  description = <<-EOF
  Config object for the Task host's launch template resource. If the "instance_type"
  is not provided, the default that will be used is "t3a.micro". Note that this default
  is subject to change over time as prices fluctuate and different features become
  available, so if a service/workload needs a particular type of instance for whatever
  reason, it is highly recommended that you provide an explicit instance type value. If
  "ami_id" is not provided, the "image_id" will default to the latest version of the
  AWS-managed "ECS Optimized" AMI. Please note that in the near future, the default will
  be changed to the Nerdware Hardened Base AMI image.
  EOF

  type = object({
    name                          = string
    description                   = optional(string)
    should_update_default_version = optional(bool) # Default: true
    instance_type                 = optional(string)
    ami_id                        = optional(string)
    user_data                     = optional(string)
    tags                          = optional(map(string))
  })
}

#---------------------------------------------------------------------
### ECS Task Definition Inputs

variable "task_definition" {
  description = <<-EOF
  Config object for the ECS Task Definition resource. "container_definitions"
  must be a JSON-encoded string; refer to AWS docs for an explanation of how
  to write valid container definitions. If "cpu" or "memory" are not provided,
  their values will be computed using the "instance_type" provided in
  var.task_host_launch_template, which currently defaults to "t3a.micro".
  EOF

  type = object({
    name                    = string
    cpu                     = optional(number)
    memory                  = optional(number)
    task_execution_role_arn = string # Used to start containers
    task_role_arn           = string # Used to access AWS resources during runtime
    container_definitions   = string
    tags                    = optional(map(string))
  })
}

#---------------------------------------------------------------------
### Capacity Provider Inputs

variable "capacity_provider" {
  description = "Config object for the capacity provider resource."
  type = object({
    name = string
    tags = optional(map(string))
  })
}

#---------------------------------------------------------------------
### AutoScaling Group Inputs

variable "autoscaling_group" {
  description = "Config object for the autoscaling group resource."
  type = object({
    name = string
    tags = optional(map(string))
  })
}

#---------------------------------------------------------------------
### Service Discovery Inputs

variable "service_discovery_service" {
  description = <<-EOF
  Config object for the Task launch template resource.
  "health_check_custom_failure_threshold", if provided, must be a number
  between 1-10 which shall implement the number of 30-second intervals
  the service discovery service should wait before it changes the health
  status of a service instance.
  EOF

  type = object({
    name = string
    dns_config = optional(object({
      namespace_id = string
      dns_records = set(object({
        type = string # DNS record type, e.g. "A"
        ttl  = number # num seconds TTL
      }))
    }))
    health_check_custom_failure_threshold = optional(number)
    tags                                  = optional(map(string))
  })
}

######################################################################
