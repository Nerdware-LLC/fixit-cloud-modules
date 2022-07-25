######################################################################
### ECS Cluster

resource "aws_ecs_cluster" "this" {
  name = var.ecs_cluster.name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  # ECS Exec
  dynamic "configuration" {
    for_each = (
      try(var.ecs_cluster.ecs_exec_config.should_enable, false) == true
      ? [var.ecs_cluster.ecs_exec_config]
      : []
    )

    content {
      execute_command_configuration {
        kms_key_id = configuration.value.kms_key_id
        logging    = "OVERRIDE"

        log_configuration {
          cloud_watch_encryption_enabled = true
          cloud_watch_log_group_name     = configuration.value.cloud_watch_log_group_name
          s3_bucket_name                 = configuration.value.s3_bucket_name
          s3_bucket_encryption_enabled   = configuration.value.s3_bucket_encryption_enabled
          s3_key_prefix                  = configuration.value.s3_key_prefix
        }
      }
    }
  }

  tags = var.ecs_cluster.tags
}

#---------------------------------------------------------------------
### ECS Cluster - Associated Capacity Providers

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = values(aws_ecs_capacity_provider.map)[*].arn

  default_capacity_provider_strategy {
    base              = 0
    weight            = 1
    capacity_provider = "FARGATE"
  }
}

######################################################################
