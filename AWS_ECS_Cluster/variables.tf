######################################################################
### INPUT VARIABLES
######################################################################
### ECS Cluster Inputs

variable "ecs_cluster" {
  description = <<-EOF
  Config object for the ECS Cluster resource object. ECS Exec will be
  disabled by default, unless "ecs_exec_config.should_enable" is true.
  "kms_key_id", if provided, will be used to encrypt the data between
  the local client and container. If you'd like to view logs from ECS
  Exec activity, you can optionally have logs sent to a CloudWatch Logs
  log group and/or an S3 Bucket.
  EOF

  type = object({
    name = string
    ecs_exec_config = optional(object({
      should_enable                = bool
      kms_key_id                   = optional(string)
      cloud_watch_log_group_name   = optional(string)
      s3_bucket_name               = optional(string)
      s3_bucket_encryption_enabled = optional(string)
      s3_key_prefix                = optional(string)
    }))
    tags = optional(map(string))
  })
}

#---------------------------------------------------------------------
### ECS Task Definition Inputs

variable "task_definitions" {
  description = <<-EOF
  Map of ECS Task Definition names to config objects. All "ecs_service" values must
  be unique, and must point to an ECS Service defined in var.ecs_services. All Task
  Definitions must include "container_definitions", a map of container-enums to container
  def config objects. Supported container-enum keys are "SERVICE", "ENVOY" - both of
  which are required - and optionally "XRAY".
  Please refer to AWS docs regarding the keys/values of ECS container definitions
  ([link here](#🔗-helpful-links)). Regarding "proxy_config", all "appmesh_node_name"
  values must be unique, and must point to an AppMesh Node defined in var.appmesh_nodes.
  "egress_ignored_ips" defaults to "169.254.170.2,169.254.169.254" if not provided.
  The ingress/egress port values default to 15000/15001. If "cpu" or "memory" are not
  provided, their values will be computed using "instance_type" if provided.
  EOF

  type = map(
    # map keys: task definition names
    object({
      ecs_service = string
      container_definitions = map(
        # map keys: "SERVICE", "ENVOY", and optionally "XRAY"
        object({
          name  = string
          image = string
          portMappings = list(object({
            containerPort = number
            hostPort      = number
            protocol      = string
          }))
          logConfiguration = object({
            logDriver = string
            options = object({
              awslogs-region        = string
              awslogs-group         = string
              awslogs-stream-prefix = string
            })
          })
          linuxParameters = optional(object({
            capabilities = object({
              add  = list(string)
              drop = list(string)
            })
          }))
          dependsOn = optional(list(object({
            containerName = string
            condition     = string
          })))
          environment = optional(list(object({
            name  = string
            value = string
          })))
          environmentFiles = optional(list(object({
            type  = string
            value = string
          })))
          cpu               = optional(number)
          memoryReservation = optional(number)
          user              = optional(string)
          healthCheck = optional(object({
            command     = list(string)
            startPeriod = number
            interval    = number
            timeout     = number
            retries     = number
          }))
        })
      )
      task_execution_role_arn = string # Used to start containers
      task_role_arn           = string # Used to access AWS resources during runtime
      instance_type           = optional(string)
      cpu                     = optional(number)
      memory                  = optional(number)
      proxy_config = object({
        appmesh_node_name  = string           # Example: "Nginx_node1"
        egress_ignored_ips = optional(string) # Default: "169.254.170.2,169.254.169.254"
        proxy_ingress_port = optional(number) # Default: 15000
        proxy_egress_port  = optional(number) # Default: 15001
      })
      tags = optional(map(string))
    })
  )

  # Ensure all "ecs_service" values are unique.
  validation {
    condition = length(values(var.task_definitions)) == length(distinct(
      values(var.task_definitions)[*].ecs_service
    ))
    error_message = "All \"ecs_service\" values must be unique."
  }

  # Ensure container_definitions keys only include "SERVICE", "ENVOY", and optionally "XRAY".
  validation {
    condition = alltrue([
      for container_defs_obj in values(var.task_definitions)[*].container_definitions : alltrue([
        for key in keys(container_defs_obj)[*] : contains(["SERVICE", "ENVOY", "XRAY"], key)
      ])
    ])
    error_message = "All \"container_definitions\" must include keys \"SERVICE\" and \"ENVOY\", and may also contain \"XRAY\"; all other keys are invalid."
  }
}

#---------------------------------------------------------------------
### ECS Service Inputs

variable "ecs_services" {
  description = <<-EOF
  Map of ECS Service names to config objects. All "capacity_provider_name"
  values must be unique, and must point to a capacity provider defined in
  var.capacity_providers. All "task_definition_name" values must be unique,
  and must point to a task definition defined in var.task_definitions. All
  "service_discovery_service" values must be unique, and must point to a
  service discovery service defined in var.service_discovery_services.
  Regarding "rolling_update_controls", set "force_new_deployment" to "true"
  after the AMI pipeline updates the service image. Min/Max default to
  100/200, respectively.
  EOF

  type = map(
    # map keys: ecs service names
    object({
      task_definition_name      = string
      capacity_provider_name    = string
      service_discovery_service = string
      network_configs = object({
        assign_public_ip   = bool
        subnet_ids         = list(string)
        security_group_ids = list(string)
      })
      rolling_update_controls = optional(object({
        force_new_deployment               = bool
        deployment_minimum_healthy_percent = optional(number)
        deployment_maximum_percent         = optional(number)
      }))
      enable_ecs_exec = optional(bool)
      tags            = optional(map(string))
    })
  )

  # Ensure all "task_definition_name" values are unique.
  validation {
    condition = length(values(var.ecs_services)) == length(distinct(
      values(var.ecs_services)[*].task_definition_name
    ))
    error_message = "All \"task_definition_name\" values must be unique."
  }

  # Ensure all "capacity_provider_name" values are unique.
  validation {
    condition = length(values(var.ecs_services)) == length(distinct(
      values(var.ecs_services)[*].capacity_provider_name
    ))
    error_message = "All \"capacity_provider_name\" values must be unique."
  }

  # Ensure all "service_discovery_service" values are unique.
  validation {
    condition = length(values(var.ecs_services)) == length(distinct(
      values(var.ecs_services)[*].service_discovery_service
    ))
    error_message = "All \"service_discovery_service\" values must be unique."
  }
}

#---------------------------------------------------------------------
### ECS Services - Capacity Provider Inputs

variable "capacity_providers" {
  description = <<-EOF
  Map of capacity provider names to config objects. All "autoscaling_group_name"
  values must be unique, and must point to an ASG defined in var.autoscaling_groups.
  The managed_scaling step_size params are both optional, and default to "1" if not
  provided. If provided, the value(s) must be between 1 and 10,000. If not provided,
  "should_enable_managed_termination_protection" defaults to "true".
  EOF

  type = map(
    # map keys: capacity provider names
    object({
      autoscaling_group_name = string
      managed_scaling = object({
        is_enabled                = bool
        minimum_scaling_step_size = optional(number)
        maximum_scaling_step_size = optional(number)
        # TODO Add params "instance_warmup_period", "target_capacity"
      })
      should_enable_managed_termination_protection = optional(bool)
      tags                                         = optional(map(string))
    })
  )

  # Ensure all "autoscaling_group_name" values are unique.
  validation {
    condition = length(values(var.capacity_providers)) == length(distinct(
      values(var.capacity_providers)[*].autoscaling_group_name
    ))
    error_message = "All \"autoscaling_group_name\" values must be unique."
  }
}

#---------------------------------------------------------------------
### ECS Services - AutoScaling Group Inputs

variable "autoscaling_groups" {
  description = <<-EOF
  Map of autoscaling group names to config objects. All "task_host_launch_template_name"
  values must be unique, and must point to a task host launch template defined in
  var.task_host_launch_templates. If not provided, "task_host_launch_template_version"
  defaults to "$Default".
  EOF

  type = map(
    # map keys: autoscaling group names
    object({
      subnet_ids                        = list(string)
      task_host_launch_template_name    = string
      task_host_launch_template_version = optional(string)
      instance_count = object({
        min     = number
        desired = number
        max     = number
      })
      tags = optional(set(object({
        key                 = string
        value               = string
        propagate_at_launch = bool
      })))
    })
  )

  # Ensure all "task_host_launch_template_name" values are unique.
  validation {
    condition = length(values(var.autoscaling_groups)) == length(distinct(
      values(var.autoscaling_groups)[*].task_host_launch_template_name
    ))
    error_message = "All \"task_host_launch_template_name\" values must be unique."
  }
}


#---------------------------------------------------------------------
### ECS Services - AutoScaling Group Launch Templates for Task Hosts

variable "task_host_launch_templates" {
  description = <<-EOF
  Map of launch template names to config objects. The launch templates configured by
  this variable define Task Hosts for ECS Service AutoScaling Groups (referred to as
  "Container Instances" in AWS documentation parlance). If "ami_id" is not provided,
  the "image_id" will default to the latest version of the AWS-managed "ECS Optimized"
  AMI. Please note that this default is subject to change.
  EOF

  type = map(
    # map keys: launch template names
    object({
      instance_type                 = string
      description                   = optional(string)
      should_update_default_version = optional(bool) # Default: true
      ami_id                        = optional(string)
      user_data                     = optional(string)
      tags                          = optional(map(string))
      tag_specifications = optional(set(object({
        resource_type = string # Refer to AWS docs for valid values
        tags          = map(string)
      })))
    })
  )
}

#---------------------------------------------------------------------
### Service Discovery Inputs

variable "service_discovery_namespace" {
  description = "Config object for the service discovery namespace."

  type = object({
    name        = string
    description = string
    vpc_id      = string
    tags        = optional(map(string))
  })
}

variable "service_discovery_services" {
  description = <<-EOF
  Map of service discovery service names to config objects. The
  "routing_policy" DNS config, if provided, can be either "MULTIVALUE" or
  "WEIGHTED". "health_check_custom_failure_threshold", if provided, must
  be a number between 1-10 which shall implement the number of 30-second
  intervals the service discovery service should wait before it changes the
  health status of a service instance.
  EOF

  type = map(
    # map keys: service discovery service names
    object({
      dns_config = optional(object({
        routing_policy = optional(string) # null, "MULTIVALUE", or "WEIGHTED"
        dns_records = set(object({
          type = string # DNS record type, e.g. "A"
          ttl  = number # num seconds TTL
        }))
      }))
      health_check_custom_failure_threshold = optional(number)
      tags                                  = optional(map(string))
    })
  )
}

#---------------------------------------------------------------------
### App Mesh Inputs

variable "appmesh_mesh" {
  description = "Config object for the App Mesh resource."

  type = object({
    name                        = string
    should_allow_egress_traffic = optional(bool)
    tags                        = optional(map(string))
  })
}

variable "appmesh_services" {
  description = <<-EOF
  Map of AppMesh Service names to config objects. All "provider_type"
  values must be either "NODE" or "ROUTER".
  EOF

  type = map(
    # map keys: service names e.g. "servicea.simpleapp.local"
    object({
      provider_type = string # "ROUTER" or "NODE"
      provider_name = string
    })
  )

  # Ensure all "provider_type" values are "NODE" or "ROUTER"
  validation {
    condition = alltrue([
      for provider_type in values(var.appmesh_services)[*].provider_type
      : contains(["NODE", "ROUTER"], provider_type)
    ])
    error_message = "All \"provider_type\" values must be either \"NODE\" or \"ROUTER\"."
  }
}

variable "appmesh_nodes" {
  description = "Map of AppMesh Node names to config objects."

  type = map(
    # map keys: node names e.g. "serviceBv1"
    object({
      service_name         = string
      service_dns_hostname = optional(string)
      listener_port_mappings = set(object({
        port     = number
        protocol = string
      }))
      cloud_map_config = optional(object({
        stack = string
      }))
      # TODO add health_check
    })
  )
}

variable "appmesh_routers" {
  description = <<-EOF
  Map of AppMesh Virtual Router names to config objects. "protocol"
  can be either "http", "http2", "tcp", or "grpc".
  EOF

  type = map(
    # map keys: router names
    object({
      port     = number
      protocol = string
      tags     = optional(map(string))
    })
  )

  default = {}
}

variable "appmesh_routes" {
  description = <<-EOF
  Map of AppMesh Route names to route config objects. "spec" must have a
  "priority" between 0-1000 and a "type", which can be "http_route" or "http2_route"
  (support for "tcp_route" and "grpc_route" will be added in the future).
  EOF

  type = map(
    # map keys: AppMesh route names e.g. "serviceB-route"
    object({
      virtual_router_name = string
      type                = string # "http_route" or "http2_route" (future support: "tcp_route"/"grpc_route")
      spec = object({
        action_targets = map(
          # map keys: appmesh node names
          object({
            weight = number
        }))
        match = object({
          prefix = string
          method = optional(string)
          scheme = optional(string) # can be "http" or "https"
          header = optional(object({
            name   = string
            invert = optional(bool)
            match = optional(object({
              exact  = optional(string)
              prefix = optional(string)
              suffix = optional(string)
              regex  = optional(string)
              range = optional(object({
                start = string
                end   = string
              }))
            }))
          }))
        })
        retry_policy = object({
          max_retries       = number
          http_retry_events = optional(list(string))
          tcp_retry_events  = optional(list(string))
          per_retry_timeout = object({
            unit : string # "ms" or "s"
            value = number
          })
        })
        idle_timeout = optional(object({
          unit : string # "ms" or "s"
          value = number
        }))
      })
      tags = optional(map(string))
    })
  )

  default = {}
}

# TODO add variable for AppMesh Gateways

######################################################################
