######################################################################
### AWS DynamoDB

# The ignored tfsec rule below pertains to DAX clusters, which this module does not yet support.
# tfsec:ignore:aws-dynamodb-enable-at-rest-encryption
resource "aws_dynamodb_table" "this" {
  name      = var.table_name
  hash_key  = var.hash_key
  range_key = var.range_key

  billing_mode   = var.billing_mode
  read_capacity  = try(var.capacity.read.max, null)
  write_capacity = try(var.capacity.write.max, null)
  table_class    = var.table_storage_class

  # ATTRIBUTES
  dynamic "attribute" {
    for_each = { for attr in var.attributes : attr.name => attr.type }

    content {
      name = attribute.key
      type = attribute.value
    }
  }

  # GLOBAL SECONDARY INDEXES
  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes != null ? var.global_secondary_indexes : {}
    iterator = "gsi"

    content {
      name               = gsi.key
      hash_key           = gsi.value.hash_key
      range_key          = gsi.value.range_key
      projection_type    = gsi.value.projection_type
      non_key_attributes = gsi.value.non_key_attributes
      read_capacity      = try(gsi.value.capacity.read.max, null)
      write_capacity     = try(gsi.value.capacity.write.max, null)
    }
  }

  # LOCAL SECONDARY INDEXES
  dynamic "local_secondary_index" {
    for_each = var.local_secondary_indexes != null ? var.local_secondary_indexes : {}
    iterator = "lsi"

    content {
      name               = lsi.key
      range_key          = lsi.value.range_key
      projection_type    = lsi.value.projection_type
      non_key_attributes = lsi.value.non_key_attributes
    }
  }

  # SSE (required)
  server_side_encryption {
    enabled     = true
    kms_key_arn = var.server_side_encryption_kms_key_arn
  }

  # TTL
  dynamic "ttl" {
    for_each = var.ttl != null ? [var.ttl] : []

    content {
      enabled        = coalesce(ttl.value.enabled, true)
      attribute_name = ttl.value.attribute_name
    }
  }

  # POINT IN TIME RECOVERY (enabled by default)
  dynamic "point_in_time_recovery" {
    for_each = var.enable_point_in_time_recovery != false ? [var.enable_point_in_time_recovery] : []

    content {
      enabled = true
    }
  }

  # RESTORE-TABLE
  restore_source_name    = lookup(var.restore_table_from, "source_table_name", null)
  restore_to_latest_time = lookup(var.restore_table_from, "use_latest_recovery_point", null)
  restore_date_time      = lookup(var.restore_table_from, "restore_date_time", null)

  # STREAM: DynamoDB Table Stream
  stream_enabled   = try(var.streams.dynamodb_stream_view_type, null) != null
  stream_view_type = try(var.streams.dynamodb_stream_view_type, null)

  # REGIONAL REPLICAS
  dynamic "replica" {
    for_each = var.replicas != null ? var.replicas : {}

    content {
      region_name            = replica.key
      propagate_tags         = replica.value.propagate_tags
      kms_key_arn            = replica.value.kms_key_arn
      point_in_time_recovery = replica.value.enable_point_in_time_recovery == false # default: true
    }
  }

  tags = var.tags

  lifecycle {
    /* TFR recommends this setting when an autoscaling policy is
    in use, which for this module is the default setting.     */
    ignore_changes = [read_capacity, write_capacity]
  }
}

#---------------------------------------------------------------------
### DynamoDB Table Item

resource "aws_dynamodb_table_item" "list" {
  count = var.dynamodb_table_items != null ? length(var.dynamodb_table_items) : 0

  table_name = aws_dynamodb_table.this.name
  hash_key   = aws_dynamodb_table.this.hash_key
  range_key  = aws_dynamodb_table.this.range_key
  item       = var.dynamodb_table_items[count.index]
}

#---------------------------------------------------------------------
### DynamoDB Stream: Kinesis Data Stream

resource "aws_dynamodb_kinesis_streaming_destination" "list" {
  count = try(var.streams.kinesis_stream_arn, null) != null ? 1 : 0

  stream_arn = var.streams.kinesis_stream_arn
  table_name = aws_dynamodb_table.this.name
}

######################################################################
