######################################################################
### DynamoDB - Provisioned Read/Write AutoScaling

locals {
  /*
    In accordance with security and performance best practices, all DynamoDB
    tables and global indexes with "PROVISIONED" read/write capacity must be
    configured to scale up+down with demand.

    Both the autoscaling TARGET and POLICY resources require a "scalable_dimension"
    property, of which there are FOUR for DynamoDB:

      dynamodb:table:ReadCapacityUnits    - The provisioned read capacity for a DynamoDB table.
      dynamodb:table:WriteCapacityUnits   - The provisioned write capacity for a DynamoDB table.
      dynamodb:index:ReadCapacityUnits    - The provisioned read capacity for a DynamoDB global secondary index.
      dynamodb:index:WriteCapacityUnits   - The provisioned write capacity for a DynamoDB global secondary index.

    Note that the index-related dimensions must be set for each GSI.
  */

  # The keys of this local are arbitrary, they merely serve to organize the autoscaling properties.
  dynamodb_autoscaling_target_configs = (
    aws_dynamodb_table.this.billing_mode == "PROVISIONED"
    ? merge(
      {
        "table/${var.table_name}/reads" = {
          resource_id               = "table/${var.table_name}"
          scalable_dimension        = "dynamodb:table:ReadCapacityUnits"
          max_capacity              = var.capacity.read.max
          target_percentage         = var.capacity.read.target_percentage
          min_capacity              = var.capacity.read.min
          autoscaling_policy_metric = "DynamoDBReadCapacityUtilization"
        }
        "table/${var.table_name}/writes" = {
          resource_id               = "table/${var.table_name}"
          scalable_dimension        = "dynamodb:table:WriteCapacityUnits"
          max_capacity              = var.capacity.write.max
          target_percentage         = var.capacity.write.target_percentage
          min_capacity              = var.capacity.write.min
          autoscaling_policy_metric = "DynamoDBWriteCapacityUtilization"
        }
      },
      {
        for gsi_name, gsi_config in coalesce(var.global_secondary_indexes, {}) : "gsi/${gsi_name}/reads" => {
          resource_id               = "table/${var.table_name}/index/${gsi_name}"
          scalable_dimension        = "dynamodb:index:ReadCapacityUnits"
          max_capacity              = gsi_config.capacity.read.max
          target_percentage         = gsi_config.capacity.read.target_percentage
          min_capacity              = gsi_config.capacity.read.min
          autoscaling_policy_metric = "DynamoDBReadCapacityUtilization"
        }
      },
      {
        for gsi_name, gsi_config in coalesce(var.global_secondary_indexes, {}) : "gsi/${gsi_name}/writes" => {
          resource_id               = "table/${var.table_name}/index/${gsi_name}"
          scalable_dimension        = "dynamodb:index:WriteCapacityUnits"
          max_capacity              = gsi_config.capacity.write.max
          target_percentage         = gsi_config.capacity.write.target_percentage
          min_capacity              = gsi_config.capacity.write.min
          autoscaling_policy_metric = "DynamoDBWriteCapacityUtilization"
        }
      }
    )
    : {} # <-- if billing_mode is PAY_PER_REQUEST
  )
}

resource "aws_appautoscaling_target" "map" {
  for_each = local.dynamodb_autoscaling_target_configs

  service_namespace  = "dynamodb"
  resource_id        = each.value.resource_id
  scalable_dimension = each.value.scalable_dimension
  max_capacity       = each.value.max_capacity
  min_capacity       = each.value.min_capacity
}

resource "aws_appautoscaling_policy" "map" {
  for_each = local.dynamodb_autoscaling_target_configs

  name               = "${each.value.autoscaling_policy_metric}:${each.value.resource_id}"
  policy_type        = "TargetTrackingScaling"
  service_namespace  = "dynamodb"
  resource_id        = each.value.resource_id
  scalable_dimension = each.value.scalable_dimension

  target_tracking_scaling_policy_configuration {
    target_value = each.value.target_percentage

    predefined_metric_specification {
      predefined_metric_type = each.value.autoscaling_policy_metric
    }
  }

  depends_on = [aws_appautoscaling_target.map]
}

######################################################################
