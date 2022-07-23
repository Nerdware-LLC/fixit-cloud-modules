######################################################################
### INPUT VARIABLES
######################################################################
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
    name                   = string
    capacity_provider_arns = optional(list(string))
    tags                   = optional(map(string))
  })
}

#---------------------------------------------------------------------
### Default Capacity Provider Inputs

variable "ecs_exec_config" {
  description = <<-EOF
  (Optional) Config object for "ECS Exec". Should not be used in production.
  "kms_key_id", if provided, will be used to encrypt the data between the local
  client and container. If you'd like to view logs from ECS Exec activity, you
  can optionally have logs sent to a CloudWatch Logs log group and/or an S3 Bucket.
  EOF

  type = object({
    should_enable_ecs_exec       = bool
    kms_key_id                   = optional(string)
    cloud_watch_log_group_name   = optional(string)
    s3_bucket_name               = optional(string)
    s3_bucket_encryption_enabled = optional(string)
    s3_key_prefix                = optional(string)
  })

  default = { should_enable_ecs_exec = false }
}

#---------------------------------------------------------------------
### Service Discovery Namespace

variable "service_discovery_namespace" {
  description = <<-EOF
  Config object for the "aws_service_discovery_private_dns_namespace" resource.
  EOF

  type = object({
    name        = string
    description = string
    vpc_id      = string
    tags        = optional(map(string))
  })
}

#---------------------------------------------------------------------
### App Mesh Inputs

variable "app_mesh" {
  description = "Config object for the App Mesh resource."

  type = object({
    name                        = string
    should_allow_egress_traffic = optional(bool)
    tags                        = optional(map(string))
  })
}

variable "app_mesh_services" {
  description = "Map of AppMesh Service names to config objects."

  type = map(
    # map keys: service names e.g. "servicea.simpleapp.local"
    object({
      provider_type = string # "ROUTER" or "NODE"
      provider_name = string
    })
  )
}

variable "app_mesh_nodes" {
  description = "Map of AppMesh Node names to config objects."

  type = map(
    # map keys: node names e.g. "serviceBv1"
    object({
      service_name    = string
      cloud_map_stack = string
      # TODO add health_check
    })
  )
}

variable "app_mesh_routers" {
  description = <<-EOF
  Map of AppMesh Virtual Router names to config objects. "protocol"
  can be either "http", "http2", "tcp", or "grpc".
  EOF

  type = map(
    # map keys: router names
    object({
      port     = number
      protocol = string
    })
  )
}

# TODO Finish app_mesh_routes var.
variable "app_mesh_routes" {
  description = <<-EOF
  Map of AppMesh Route names to route config objects. "spec" must have a
  "priority" between 0-1000 and a "type", which can be "http_route", "http2_route",
  "tcp_route", or "grpc_route".
  EOF

  type = map(
    # map keys: AppMesh route names e.g. "serviceB-route"
    object({
      virtual_router_name = string
      type                = string # "http_route", "http2_route", "tcp_route", or "grpc_route"
      spec = object({
        action = string
        match = optional(object({
          method = string
          prefix = string
        }))
        retry_policy = string
        timeout      = number
      })
      tags = optional(map(string))
    })
  )
}

######################################################################
