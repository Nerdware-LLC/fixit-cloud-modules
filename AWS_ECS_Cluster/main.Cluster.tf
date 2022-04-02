######################################################################
### ECS Cluster

resource "aws_ecs_cluster" "this" {
  name = var.ecs_cluster.name

  capacity_providers = flatten([
    var.ecs_cluster.capacity_provider_arns,
    aws_ecs_capacity_provider.Default_CapacityProvider.arn
  ])

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.Default_CapacityProvider.arn
    base              = 0
    weight            = 1
  }

  setting {
    name  = "containerInsights"
    value = var.ecs_cluster.should_enable_container_insights != false ? "enabled" : "disabled"
  }

  # Enable ECS Exec ONLY if a KMS Key ARN was provided (should only ever be used in non-prod envs)
  dynamic "configuration" {
    for_each = (one(data.aws_kms_alias.ECS_Exec_Key) != null
      ? { kms_key_id = one(data.aws_kms_alias.ECS_Exec_Key).arn }
      : {}
    )
    content {
      execute_command_configuration {
        kms_key_id = configuration.value
        logging    = "OVERRIDE"

        log_configuration {
          cloud_watch_encryption_enabled = true
          cloud_watch_log_group_name     = aws_cloudwatch_log_group.ECS_Cluster_Cloudwatch_LogGroup.name
        }
      }
    }
  }

  tags = var.ecs_cluster.tags
}

data "aws_kms_alias" "ECS_Exec_Key" {
  count = var.ecs_cluster.ecs_exec_kms_key_alias != null ? 1 : 0

  name = var.ecs_cluster.ecs_exec_kms_key_alias
}

#---------------------------------------------------------------------
### ECS Cluster CloudWatch Logs Log Group

resource "aws_cloudwatch_log_group" "ECS_Cluster_CloudWatch_LogGroup" {
  name              = var.ecs_cluster.cloudwatch_log_group.name
  retention_in_days = coalesce(var.ecs_cluster.cloudwatch_log_group.retention_in_days, 400)
  kms_key_id        = data.aws_kms_alias.ECS_Cluster_CloudWatch_LogGroup.arn
  tags              = var.ecs_cluster.cloudwatch_log_group.tags
}

data "aws_kms_alias" "ECS_Cluster_CloudWatch_LogGroup" {
  name = var.ecs_cluster.cloudwatch_log_group.kms_key_alias
}

######################################################################
