######################################################################
### AWS Config
######################################################################
### AWS Config - Organization Aggregator

resource "aws_config_configuration_aggregator" "list" {
  count = var.config_aggregator != null ? 1 : 0

  name = var.config_aggregator.name
  tags = var.config_aggregator.tags

  organization_aggregation_source {
    all_regions = true
    role_arn    = var.config_aggregator.iam_service_role_arn
  }
}

######################################################################
### REGION-SPECIFIC CONFIG RESOURCES

locals {
  delivery_channel_snapshot_frequency = coalesce(
    var.config_delivery_channels.snapshot_frequency,
    "TwentyFour_Hours"
  )
}

#---------------------------------------------------------------------
### Config - us-east-2 (HOME REGION USES IMPLICIT/DEFAULT PROVIDER)

resource "aws_config_configuration_recorder" "us-east-2" {
  name     = var.config_recorders.name
  role_arn = var.config_recorders.role_arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = local.IS_ROOT_ACCOUNT == true # Only in us-east-2
  }

  lifecycle {
    /* As of 1/2/22, TF plans constantly showed a diff for the below attribute
    (shows live version has resource_types = []), which is NOT included bc TFR
    docs say it conflicts with recording_group's other 2 attrs, which we use. */
    ignore_changes = [recording_group[0].resource_types]
  }
}

resource "aws_config_configuration_recorder_status" "us-east-2" {
  name       = aws_config_configuration_recorder.us-east-2.id
  is_enabled = true

  depends_on = [aws_config_delivery_channel.us-east-2]
}

resource "aws_config_delivery_channel" "us-east-2" {
  name           = var.config_delivery_channels.name
  s3_bucket_name = var.config_delivery_channels.s3_bucket.name
  s3_key_prefix  = var.config_delivery_channels.s3_bucket.key_prefix
  s3_kms_key_arn = var.config_delivery_channels.s3_bucket.sse_kms_key_arn
  sns_topic_arn  = "arn:aws:sns:us-east-2:${local.root_account_id}:${var.config_sns_topics.name}"

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_channel_snapshot_frequency
  }

  depends_on = [aws_config_configuration_recorder.us-east-2]
}

resource "aws_sns_topic" "us-east-2" {
  count = local.IS_ROOT_ACCOUNT ? 1 : 0

  name              = var.config_sns_topics.name
  display_name      = var.config_sns_topics.display_name
  kms_master_key_id = var.config_sns_topics.kms_master_key_id
  tags              = var.config_sns_topics.tags
}

resource "aws_sns_topic_policy" "us-east-2" {
  count = local.IS_ROOT_ACCOUNT && var.config_sns_topic != null ? 1 : 0

  arn = one(aws_sns_topic.us-east-2).arn
  policy = templatefile("${path.module}/templates/Config_SNS_Topic_Policy.json.tftpl", {
    sns_topic_arn   = one(aws_sns_topic.us-east-2).arn
    org_id          = local.org_id
    all_account_ids = local.all_account_ids
  })
}

#---------------------------------------------------------------------
### Config - ap-northeast-1

resource "aws_config_configuration_recorder" "ap-northeast-1" {
  provider = aws.ap-northeast-1

  name     = var.config_recorders.name
  role_arn = var.config_recorders.role_arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = false
  }

  lifecycle {
    /* As of 1/2/22, TF plans constantly showed a diff for the below attribute
    (shows live version has resource_types = []), which is NOT included bc TFR
    docs say it conflicts with recording_group's other 2 attrs, which we use. */
    ignore_changes = [recording_group[0].resource_types]
  }
}

resource "aws_config_configuration_recorder_status" "ap-northeast-1" {
  provider = aws.ap-northeast-1

  name       = aws_config_configuration_recorder.ap-northeast-1.id
  is_enabled = true

  depends_on = [aws_config_delivery_channel.ap-northeast-1]
}

resource "aws_config_delivery_channel" "ap-northeast-1" {
  provider = aws.ap-northeast-1

  name           = var.config_delivery_channels.name
  s3_bucket_name = var.config_delivery_channels.s3_bucket.name
  s3_key_prefix  = var.config_delivery_channels.s3_bucket.key_prefix
  s3_kms_key_arn = var.config_delivery_channels.s3_bucket.sse_kms_key_arn
  sns_topic_arn  = "arn:aws:sns:ap-northeast-1:${local.root_account_id}:${var.config_sns_topics.name}"

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_channel_snapshot_frequency
  }

  depends_on = [aws_config_configuration_recorder.ap-northeast-1]
}

resource "aws_sns_topic" "ap-northeast-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.ap-northeast-1

  name              = var.config_sns_topics.name
  display_name      = var.config_sns_topics.display_name
  kms_master_key_id = var.config_sns_topics.kms_master_key_id
  tags              = var.config_sns_topics.tags
}

resource "aws_sns_topic_policy" "ap-northeast-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.ap-northeast-1

  arn = one(aws_sns_topic.ap-northeast-1).arn
  policy = templatefile("${path.module}/templates/Config_SNS_Topic_Policy.json.tftpl", {
    sns_topic_arn   = one(aws_sns_topic.ap-northeast-1).arn
    org_id          = local.org_id
    all_account_ids = local.all_account_ids
  })
}

#---------------------------------------------------------------------
### Config - ap-northeast-2

resource "aws_config_configuration_recorder" "ap-northeast-2" {
  provider = aws.ap-northeast-2

  name     = var.config_recorders.name
  role_arn = var.config_recorders.role_arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = false
  }

  lifecycle {
    /* As of 1/2/22, TF plans constantly showed a diff for the below attribute
    (shows live version has resource_types = []), which is NOT included bc TFR
    docs say it conflicts with recording_group's other 2 attrs, which we use. */
    ignore_changes = [recording_group[0].resource_types]
  }
}

resource "aws_config_configuration_recorder_status" "ap-northeast-2" {
  provider = aws.ap-northeast-2

  name       = aws_config_configuration_recorder.ap-northeast-2.id
  is_enabled = true

  depends_on = [aws_config_delivery_channel.ap-northeast-2]
}

resource "aws_config_delivery_channel" "ap-northeast-2" {
  provider = aws.ap-northeast-2

  name           = var.config_delivery_channels.name
  s3_bucket_name = var.config_delivery_channels.s3_bucket.name
  s3_key_prefix  = var.config_delivery_channels.s3_bucket.key_prefix
  s3_kms_key_arn = var.config_delivery_channels.s3_bucket.sse_kms_key_arn
  sns_topic_arn  = "arn:aws:sns:ap-northeast-2:${local.root_account_id}:${var.config_sns_topics.name}"

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_channel_snapshot_frequency
  }

  depends_on = [aws_config_configuration_recorder.ap-northeast-2]
}

resource "aws_sns_topic" "ap-northeast-2" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.ap-northeast-2

  name              = var.config_sns_topics.name
  display_name      = var.config_sns_topics.display_name
  kms_master_key_id = var.config_sns_topics.kms_master_key_id
  tags              = var.config_sns_topics.tags
}

resource "aws_sns_topic_policy" "ap-northeast-2" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.ap-northeast-2

  arn = one(aws_sns_topic.ap-northeast-2).arn
  policy = templatefile("${path.module}/templates/Config_SNS_Topic_Policy.json.tftpl", {
    sns_topic_arn   = one(aws_sns_topic.ap-northeast-2).arn
    org_id          = local.org_id
    all_account_ids = local.all_account_ids
  })
}

#---------------------------------------------------------------------
### Config - ap-northeast-3

resource "aws_config_configuration_recorder" "ap-northeast-3" {
  provider = aws.ap-northeast-3

  name     = var.config_recorders.name
  role_arn = var.config_recorders.role_arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = false
  }

  lifecycle {
    /* As of 1/2/22, TF plans constantly showed a diff for the below attribute
    (shows live version has resource_types = []), which is NOT included bc TFR
    docs say it conflicts with recording_group's other 2 attrs, which we use. */
    ignore_changes = [recording_group[0].resource_types]
  }
}

resource "aws_config_configuration_recorder_status" "ap-northeast-3" {
  provider = aws.ap-northeast-3

  name       = aws_config_configuration_recorder.ap-northeast-3.id
  is_enabled = true

  depends_on = [aws_config_delivery_channel.ap-northeast-3]
}

resource "aws_config_delivery_channel" "ap-northeast-3" {
  provider = aws.ap-northeast-3

  name           = var.config_delivery_channels.name
  s3_bucket_name = var.config_delivery_channels.s3_bucket.name
  s3_key_prefix  = var.config_delivery_channels.s3_bucket.key_prefix
  s3_kms_key_arn = var.config_delivery_channels.s3_bucket.sse_kms_key_arn
  sns_topic_arn  = "arn:aws:sns:ap-northeast-3:${local.root_account_id}:${var.config_sns_topics.name}"

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_channel_snapshot_frequency
  }

  depends_on = [aws_config_configuration_recorder.ap-northeast-3]
}

resource "aws_sns_topic" "ap-northeast-3" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.ap-northeast-3

  name              = var.config_sns_topics.name
  display_name      = var.config_sns_topics.display_name
  kms_master_key_id = var.config_sns_topics.kms_master_key_id
  tags              = var.config_sns_topics.tags
}

resource "aws_sns_topic_policy" "ap-northeast-3" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.ap-northeast-3

  arn = one(aws_sns_topic.ap-northeast-3).arn
  policy = templatefile("${path.module}/templates/Config_SNS_Topic_Policy.json.tftpl", {
    sns_topic_arn   = one(aws_sns_topic.ap-northeast-3).arn
    org_id          = local.org_id
    all_account_ids = local.all_account_ids
  })
}

#---------------------------------------------------------------------
### Config - ap-south-1

resource "aws_config_configuration_recorder" "ap-south-1" {
  provider = aws.ap-south-1

  name     = var.config_recorders.name
  role_arn = var.config_recorders.role_arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = false
  }

  lifecycle {
    /* As of 1/2/22, TF plans constantly showed a diff for the below attribute
    (shows live version has resource_types = []), which is NOT included bc TFR
    docs say it conflicts with recording_group's other 2 attrs, which we use. */
    ignore_changes = [recording_group[0].resource_types]
  }
}

resource "aws_config_configuration_recorder_status" "ap-south-1" {
  provider = aws.ap-south-1

  name       = aws_config_configuration_recorder.ap-south-1.id
  is_enabled = true

  depends_on = [aws_config_delivery_channel.ap-south-1]
}

resource "aws_config_delivery_channel" "ap-south-1" {
  provider = aws.ap-south-1

  name           = var.config_delivery_channels.name
  s3_bucket_name = var.config_delivery_channels.s3_bucket.name
  s3_key_prefix  = var.config_delivery_channels.s3_bucket.key_prefix
  s3_kms_key_arn = var.config_delivery_channels.s3_bucket.sse_kms_key_arn
  sns_topic_arn  = "arn:aws:sns:ap-south-1:${local.root_account_id}:${var.config_sns_topics.name}"

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_channel_snapshot_frequency
  }

  depends_on = [aws_config_configuration_recorder.ap-south-1]
}

resource "aws_sns_topic" "ap-south-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.ap-south-1

  name              = var.config_sns_topics.name
  display_name      = var.config_sns_topics.display_name
  kms_master_key_id = var.config_sns_topics.kms_master_key_id
  tags              = var.config_sns_topics.tags
}

resource "aws_sns_topic_policy" "ap-south-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.ap-south-1

  arn = one(aws_sns_topic.ap-south-1).arn
  policy = templatefile("${path.module}/templates/Config_SNS_Topic_Policy.json.tftpl", {
    sns_topic_arn   = one(aws_sns_topic.ap-south-1).arn
    org_id          = local.org_id
    all_account_ids = local.all_account_ids
  })
}

#---------------------------------------------------------------------
### Config - ap-southeast-1

resource "aws_config_configuration_recorder" "ap-southeast-1" {
  provider = aws.ap-southeast-1

  name     = var.config_recorders.name
  role_arn = var.config_recorders.role_arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = false
  }

  lifecycle {
    /* As of 1/2/22, TF plans constantly showed a diff for the below attribute
    (shows live version has resource_types = []), which is NOT included bc TFR
    docs say it conflicts with recording_group's other 2 attrs, which we use. */
    ignore_changes = [recording_group[0].resource_types]
  }
}

resource "aws_config_configuration_recorder_status" "ap-southeast-1" {
  provider = aws.ap-southeast-1

  name       = aws_config_configuration_recorder.ap-southeast-1.id
  is_enabled = true

  depends_on = [aws_config_delivery_channel.ap-southeast-1]
}

resource "aws_config_delivery_channel" "ap-southeast-1" {
  provider = aws.ap-southeast-1

  name           = var.config_delivery_channels.name
  s3_bucket_name = var.config_delivery_channels.s3_bucket.name
  s3_key_prefix  = var.config_delivery_channels.s3_bucket.key_prefix
  s3_kms_key_arn = var.config_delivery_channels.s3_bucket.sse_kms_key_arn
  sns_topic_arn  = "arn:aws:sns:ap-southeast-1:${local.root_account_id}:${var.config_sns_topics.name}"

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_channel_snapshot_frequency
  }

  depends_on = [aws_config_configuration_recorder.ap-southeast-1]
}

resource "aws_sns_topic" "ap-southeast-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.ap-southeast-1

  name              = var.config_sns_topics.name
  display_name      = var.config_sns_topics.display_name
  kms_master_key_id = var.config_sns_topics.kms_master_key_id
  tags              = var.config_sns_topics.tags
}

resource "aws_sns_topic_policy" "ap-southeast-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.ap-southeast-1

  arn = one(aws_sns_topic.ap-southeast-1).arn
  policy = templatefile("${path.module}/templates/Config_SNS_Topic_Policy.json.tftpl", {
    sns_topic_arn   = one(aws_sns_topic.ap-southeast-1).arn
    org_id          = local.org_id
    all_account_ids = local.all_account_ids
  })
}

#---------------------------------------------------------------------
### Config - ap-southeast-2

resource "aws_config_configuration_recorder" "ap-southeast-2" {
  provider = aws.ap-southeast-2

  name     = var.config_recorders.name
  role_arn = var.config_recorders.role_arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = false
  }

  lifecycle {
    /* As of 1/2/22, TF plans constantly showed a diff for the below attribute
    (shows live version has resource_types = []), which is NOT included bc TFR
    docs say it conflicts with recording_group's other 2 attrs, which we use. */
    ignore_changes = [recording_group[0].resource_types]
  }
}

resource "aws_config_configuration_recorder_status" "ap-southeast-2" {
  provider = aws.ap-southeast-2

  name       = aws_config_configuration_recorder.ap-southeast-2.id
  is_enabled = true

  depends_on = [aws_config_delivery_channel.ap-southeast-2]
}

resource "aws_config_delivery_channel" "ap-southeast-2" {
  provider = aws.ap-southeast-2

  name           = var.config_delivery_channels.name
  s3_bucket_name = var.config_delivery_channels.s3_bucket.name
  s3_key_prefix  = var.config_delivery_channels.s3_bucket.key_prefix
  s3_kms_key_arn = var.config_delivery_channels.s3_bucket.sse_kms_key_arn
  sns_topic_arn  = "arn:aws:sns:ap-southeast-2:${local.root_account_id}:${var.config_sns_topics.name}"

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_channel_snapshot_frequency
  }

  depends_on = [aws_config_configuration_recorder.ap-southeast-2]
}

resource "aws_sns_topic" "ap-southeast-2" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.ap-southeast-2

  name              = var.config_sns_topics.name
  display_name      = var.config_sns_topics.display_name
  kms_master_key_id = var.config_sns_topics.kms_master_key_id
  tags              = var.config_sns_topics.tags
}

resource "aws_sns_topic_policy" "ap-southeast-2" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.ap-southeast-2

  arn = one(aws_sns_topic.ap-southeast-2).arn
  policy = templatefile("${path.module}/templates/Config_SNS_Topic_Policy.json.tftpl", {
    sns_topic_arn   = one(aws_sns_topic.ap-southeast-2).arn
    org_id          = local.org_id
    all_account_ids = local.all_account_ids
  })
}

#---------------------------------------------------------------------
### Config - ca-central-1

resource "aws_config_configuration_recorder" "ca-central-1" {
  provider = aws.ca-central-1

  name     = var.config_recorders.name
  role_arn = var.config_recorders.role_arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = false
  }

  lifecycle {
    /* As of 1/2/22, TF plans constantly showed a diff for the below attribute
    (shows live version has resource_types = []), which is NOT included bc TFR
    docs say it conflicts with recording_group's other 2 attrs, which we use. */
    ignore_changes = [recording_group[0].resource_types]
  }
}

resource "aws_config_configuration_recorder_status" "ca-central-1" {
  provider = aws.ca-central-1

  name       = aws_config_configuration_recorder.ca-central-1.id
  is_enabled = true

  depends_on = [aws_config_delivery_channel.ca-central-1]
}

resource "aws_config_delivery_channel" "ca-central-1" {
  provider = aws.ca-central-1

  name           = var.config_delivery_channels.name
  s3_bucket_name = var.config_delivery_channels.s3_bucket.name
  s3_key_prefix  = var.config_delivery_channels.s3_bucket.key_prefix
  s3_kms_key_arn = var.config_delivery_channels.s3_bucket.sse_kms_key_arn
  sns_topic_arn  = "arn:aws:sns:ca-central-1:${local.root_account_id}:${var.config_sns_topics.name}"

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_channel_snapshot_frequency
  }

  depends_on = [aws_config_configuration_recorder.ca-central-1]
}

resource "aws_sns_topic" "ca-central-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.ca-central-1

  name              = var.config_sns_topics.name
  display_name      = var.config_sns_topics.display_name
  kms_master_key_id = var.config_sns_topics.kms_master_key_id
  tags              = var.config_sns_topics.tags
}

resource "aws_sns_topic_policy" "ca-central-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.ca-central-1

  arn = one(aws_sns_topic.ca-central-1).arn
  policy = templatefile("${path.module}/templates/Config_SNS_Topic_Policy.json.tftpl", {
    sns_topic_arn   = one(aws_sns_topic.ca-central-1).arn
    org_id          = local.org_id
    all_account_ids = local.all_account_ids
  })
}

#---------------------------------------------------------------------
### Config - eu-north-1

resource "aws_config_configuration_recorder" "eu-north-1" {
  provider = aws.eu-north-1

  name     = var.config_recorders.name
  role_arn = var.config_recorders.role_arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = false
  }

  lifecycle {
    /* As of 1/2/22, TF plans constantly showed a diff for the below attribute
    (shows live version has resource_types = []), which is NOT included bc TFR
    docs say it conflicts with recording_group's other 2 attrs, which we use. */
    ignore_changes = [recording_group[0].resource_types]
  }
}

resource "aws_config_configuration_recorder_status" "eu-north-1" {
  provider = aws.eu-north-1

  name       = aws_config_configuration_recorder.eu-north-1.id
  is_enabled = true

  depends_on = [aws_config_delivery_channel.eu-north-1]
}

resource "aws_config_delivery_channel" "eu-north-1" {
  provider = aws.eu-north-1

  name           = var.config_delivery_channels.name
  s3_bucket_name = var.config_delivery_channels.s3_bucket.name
  s3_key_prefix  = var.config_delivery_channels.s3_bucket.key_prefix
  s3_kms_key_arn = var.config_delivery_channels.s3_bucket.sse_kms_key_arn
  sns_topic_arn  = "arn:aws:sns:eu-north-1:${local.root_account_id}:${var.config_sns_topics.name}"

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_channel_snapshot_frequency
  }

  depends_on = [aws_config_configuration_recorder.eu-north-1]
}

resource "aws_sns_topic" "eu-north-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.eu-north-1

  name              = var.config_sns_topics.name
  display_name      = var.config_sns_topics.display_name
  kms_master_key_id = var.config_sns_topics.kms_master_key_id
  tags              = var.config_sns_topics.tags
}

resource "aws_sns_topic_policy" "eu-north-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.eu-north-1

  arn = one(aws_sns_topic.eu-north-1).arn
  policy = templatefile("${path.module}/templates/Config_SNS_Topic_Policy.json.tftpl", {
    sns_topic_arn   = one(aws_sns_topic.eu-north-1).arn
    org_id          = local.org_id
    all_account_ids = local.all_account_ids
  })
}

#---------------------------------------------------------------------
### Config - eu-central-1

resource "aws_config_configuration_recorder" "eu-central-1" {
  provider = aws.eu-central-1

  name     = var.config_recorders.name
  role_arn = var.config_recorders.role_arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = false
  }

  lifecycle {
    /* As of 1/2/22, TF plans constantly showed a diff for the below attribute
    (shows live version has resource_types = []), which is NOT included bc TFR
    docs say it conflicts with recording_group's other 2 attrs, which we use. */
    ignore_changes = [recording_group[0].resource_types]
  }
}

resource "aws_config_configuration_recorder_status" "eu-central-1" {
  provider = aws.eu-central-1

  name       = aws_config_configuration_recorder.eu-central-1.id
  is_enabled = true

  depends_on = [aws_config_delivery_channel.eu-central-1]
}

resource "aws_config_delivery_channel" "eu-central-1" {
  provider = aws.eu-central-1

  name           = var.config_delivery_channels.name
  s3_bucket_name = var.config_delivery_channels.s3_bucket.name
  s3_key_prefix  = var.config_delivery_channels.s3_bucket.key_prefix
  s3_kms_key_arn = var.config_delivery_channels.s3_bucket.sse_kms_key_arn
  sns_topic_arn  = "arn:aws:sns:eu-central-1:${local.root_account_id}:${var.config_sns_topics.name}"

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_channel_snapshot_frequency
  }

  depends_on = [aws_config_configuration_recorder.eu-central-1]
}

resource "aws_sns_topic" "eu-central-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.eu-central-1

  name              = var.config_sns_topics.name
  display_name      = var.config_sns_topics.display_name
  kms_master_key_id = var.config_sns_topics.kms_master_key_id
  tags              = var.config_sns_topics.tags
}

resource "aws_sns_topic_policy" "eu-central-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.eu-central-1

  arn = one(aws_sns_topic.eu-central-1).arn
  policy = templatefile("${path.module}/templates/Config_SNS_Topic_Policy.json.tftpl", {
    sns_topic_arn   = one(aws_sns_topic.eu-central-1).arn
    org_id          = local.org_id
    all_account_ids = local.all_account_ids
  })
}

#---------------------------------------------------------------------
### Config - eu-west-1

resource "aws_config_configuration_recorder" "eu-west-1" {
  provider = aws.eu-west-1

  name     = var.config_recorders.name
  role_arn = var.config_recorders.role_arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = false
  }

  lifecycle {
    /* As of 1/2/22, TF plans constantly showed a diff for the below attribute
    (shows live version has resource_types = []), which is NOT included bc TFR
    docs say it conflicts with recording_group's other 2 attrs, which we use. */
    ignore_changes = [recording_group[0].resource_types]
  }
}

resource "aws_config_configuration_recorder_status" "eu-west-1" {
  provider = aws.eu-west-1

  name       = aws_config_configuration_recorder.eu-west-1.id
  is_enabled = true

  depends_on = [aws_config_delivery_channel.eu-west-1]
}

resource "aws_config_delivery_channel" "eu-west-1" {
  provider = aws.eu-west-1

  name           = var.config_delivery_channels.name
  s3_bucket_name = var.config_delivery_channels.s3_bucket.name
  s3_key_prefix  = var.config_delivery_channels.s3_bucket.key_prefix
  s3_kms_key_arn = var.config_delivery_channels.s3_bucket.sse_kms_key_arn
  sns_topic_arn  = "arn:aws:sns:eu-west-1:${local.root_account_id}:${var.config_sns_topics.name}"

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_channel_snapshot_frequency
  }

  depends_on = [aws_config_configuration_recorder.eu-west-1]
}

resource "aws_sns_topic" "eu-west-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.eu-west-1

  name              = var.config_sns_topics.name
  display_name      = var.config_sns_topics.display_name
  kms_master_key_id = var.config_sns_topics.kms_master_key_id
  tags              = var.config_sns_topics.tags
}

resource "aws_sns_topic_policy" "eu-west-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.eu-west-1

  arn = one(aws_sns_topic.eu-west-1).arn
  policy = templatefile("${path.module}/templates/Config_SNS_Topic_Policy.json.tftpl", {
    sns_topic_arn   = one(aws_sns_topic.eu-west-1).arn
    org_id          = local.org_id
    all_account_ids = local.all_account_ids
  })
}

#---------------------------------------------------------------------
### Config - eu-west-2

resource "aws_config_configuration_recorder" "eu-west-2" {
  provider = aws.eu-west-2

  name     = var.config_recorders.name
  role_arn = var.config_recorders.role_arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = false
  }

  lifecycle {
    /* As of 1/2/22, TF plans constantly showed a diff for the below attribute
    (shows live version has resource_types = []), which is NOT included bc TFR
    docs say it conflicts with recording_group's other 2 attrs, which we use. */
    ignore_changes = [recording_group[0].resource_types]
  }
}

resource "aws_config_configuration_recorder_status" "eu-west-2" {
  provider = aws.eu-west-2

  name       = aws_config_configuration_recorder.eu-west-2.id
  is_enabled = true

  depends_on = [aws_config_delivery_channel.eu-west-2]
}

resource "aws_config_delivery_channel" "eu-west-2" {
  provider = aws.eu-west-2

  name           = var.config_delivery_channels.name
  s3_bucket_name = var.config_delivery_channels.s3_bucket.name
  s3_key_prefix  = var.config_delivery_channels.s3_bucket.key_prefix
  s3_kms_key_arn = var.config_delivery_channels.s3_bucket.sse_kms_key_arn
  sns_topic_arn  = "arn:aws:sns:eu-west-2:${local.root_account_id}:${var.config_sns_topics.name}"

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_channel_snapshot_frequency
  }

  depends_on = [aws_config_configuration_recorder.eu-west-2]
}

resource "aws_sns_topic" "eu-west-2" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.eu-west-2

  name              = var.config_sns_topics.name
  display_name      = var.config_sns_topics.display_name
  kms_master_key_id = var.config_sns_topics.kms_master_key_id
  tags              = var.config_sns_topics.tags
}

resource "aws_sns_topic_policy" "eu-west-2" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.eu-west-2

  arn = one(aws_sns_topic.eu-west-2).arn
  policy = templatefile("${path.module}/templates/Config_SNS_Topic_Policy.json.tftpl", {
    sns_topic_arn   = one(aws_sns_topic.eu-west-2).arn
    org_id          = local.org_id
    all_account_ids = local.all_account_ids
  })
}

#---------------------------------------------------------------------
### Config - eu-west-3

resource "aws_config_configuration_recorder" "eu-west-3" {
  provider = aws.eu-west-3

  name     = var.config_recorders.name
  role_arn = var.config_recorders.role_arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = false
  }

  lifecycle {
    /* As of 1/2/22, TF plans constantly showed a diff for the below attribute
    (shows live version has resource_types = []), which is NOT included bc TFR
    docs say it conflicts with recording_group's other 2 attrs, which we use. */
    ignore_changes = [recording_group[0].resource_types]
  }
}

resource "aws_config_configuration_recorder_status" "eu-west-3" {
  provider = aws.eu-west-3

  name       = aws_config_configuration_recorder.eu-west-3.id
  is_enabled = true

  depends_on = [aws_config_delivery_channel.eu-west-3]
}

resource "aws_config_delivery_channel" "eu-west-3" {
  provider = aws.eu-west-3

  name           = var.config_delivery_channels.name
  s3_bucket_name = var.config_delivery_channels.s3_bucket.name
  s3_key_prefix  = var.config_delivery_channels.s3_bucket.key_prefix
  s3_kms_key_arn = var.config_delivery_channels.s3_bucket.sse_kms_key_arn
  sns_topic_arn  = "arn:aws:sns:eu-west-3:${local.root_account_id}:${var.config_sns_topics.name}"

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_channel_snapshot_frequency
  }

  depends_on = [aws_config_configuration_recorder.eu-west-3]
}

resource "aws_sns_topic" "eu-west-3" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.eu-west-3

  name              = var.config_sns_topics.name
  display_name      = var.config_sns_topics.display_name
  kms_master_key_id = var.config_sns_topics.kms_master_key_id
  tags              = var.config_sns_topics.tags
}

resource "aws_sns_topic_policy" "eu-west-3" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.eu-west-3

  arn = one(aws_sns_topic.eu-west-3).arn
  policy = templatefile("${path.module}/templates/Config_SNS_Topic_Policy.json.tftpl", {
    sns_topic_arn   = one(aws_sns_topic.eu-west-3).arn
    org_id          = local.org_id
    all_account_ids = local.all_account_ids
  })
}

#---------------------------------------------------------------------
### Config - sa-east-1

resource "aws_config_configuration_recorder" "sa-east-1" {
  provider = aws.sa-east-1

  name     = var.config_recorders.name
  role_arn = var.config_recorders.role_arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = false
  }

  lifecycle {
    /* As of 1/2/22, TF plans constantly showed a diff for the below attribute
    (shows live version has resource_types = []), which is NOT included bc TFR
    docs say it conflicts with recording_group's other 2 attrs, which we use. */
    ignore_changes = [recording_group[0].resource_types]
  }
}

resource "aws_config_configuration_recorder_status" "sa-east-1" {
  provider = aws.sa-east-1

  name       = aws_config_configuration_recorder.sa-east-1.id
  is_enabled = true

  depends_on = [aws_config_delivery_channel.sa-east-1]
}

resource "aws_config_delivery_channel" "sa-east-1" {
  provider = aws.sa-east-1

  name           = var.config_delivery_channels.name
  s3_bucket_name = var.config_delivery_channels.s3_bucket.name
  s3_key_prefix  = var.config_delivery_channels.s3_bucket.key_prefix
  s3_kms_key_arn = var.config_delivery_channels.s3_bucket.sse_kms_key_arn
  sns_topic_arn  = "arn:aws:sns:sa-east-1:${local.root_account_id}:${var.config_sns_topics.name}"

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_channel_snapshot_frequency
  }

  depends_on = [aws_config_configuration_recorder.sa-east-1]
}

resource "aws_sns_topic" "sa-east-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.sa-east-1

  name              = var.config_sns_topics.name
  display_name      = var.config_sns_topics.display_name
  kms_master_key_id = var.config_sns_topics.kms_master_key_id
  tags              = var.config_sns_topics.tags
}

resource "aws_sns_topic_policy" "sa-east-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.sa-east-1

  arn = one(aws_sns_topic.sa-east-1).arn
  policy = templatefile("${path.module}/templates/Config_SNS_Topic_Policy.json.tftpl", {
    sns_topic_arn   = one(aws_sns_topic.sa-east-1).arn
    org_id          = local.org_id
    all_account_ids = local.all_account_ids
  })
}

#---------------------------------------------------------------------
### Config - us-east-1

resource "aws_config_configuration_recorder" "us-east-1" {
  provider = aws.us-east-1

  name     = var.config_recorders.name
  role_arn = var.config_recorders.role_arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = false
  }

  lifecycle {
    /* As of 1/2/22, TF plans constantly showed a diff for the below attribute
    (shows live version has resource_types = []), which is NOT included bc TFR
    docs say it conflicts with recording_group's other 2 attrs, which we use. */
    ignore_changes = [recording_group[0].resource_types]
  }
}

resource "aws_config_configuration_recorder_status" "us-east-1" {
  provider = aws.us-east-1

  name       = aws_config_configuration_recorder.us-east-1.id
  is_enabled = true

  depends_on = [aws_config_delivery_channel.us-east-1]
}

resource "aws_config_delivery_channel" "us-east-1" {
  provider = aws.us-east-1

  name           = var.config_delivery_channels.name
  s3_bucket_name = var.config_delivery_channels.s3_bucket.name
  s3_key_prefix  = var.config_delivery_channels.s3_bucket.key_prefix
  s3_kms_key_arn = var.config_delivery_channels.s3_bucket.sse_kms_key_arn
  sns_topic_arn  = "arn:aws:sns:us-east-1:${local.root_account_id}:${var.config_sns_topics.name}"

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_channel_snapshot_frequency
  }

  depends_on = [aws_config_configuration_recorder.us-east-1]
}

resource "aws_sns_topic" "us-east-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.us-east-1

  name              = var.config_sns_topics.name
  display_name      = var.config_sns_topics.display_name
  kms_master_key_id = var.config_sns_topics.kms_master_key_id
  tags              = var.config_sns_topics.tags
}

resource "aws_sns_topic_policy" "us-east-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.us-east-1

  arn = one(aws_sns_topic.us-east-1).arn
  policy = templatefile("${path.module}/templates/Config_SNS_Topic_Policy.json.tftpl", {
    sns_topic_arn   = one(aws_sns_topic.us-east-1).arn
    org_id          = local.org_id
    all_account_ids = local.all_account_ids
  })
}

#---------------------------------------------------------------------
### Config - us-west-1

resource "aws_config_configuration_recorder" "us-west-1" {
  provider = aws.us-west-1

  name     = var.config_recorders.name
  role_arn = var.config_recorders.role_arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = false
  }

  lifecycle {
    /* As of 1/2/22, TF plans constantly showed a diff for the below attribute
    (shows live version has resource_types = []), which is NOT included bc TFR
    docs say it conflicts with recording_group's other 2 attrs, which we use. */
    ignore_changes = [recording_group[0].resource_types]
  }
}

resource "aws_config_configuration_recorder_status" "us-west-1" {
  provider = aws.us-west-1

  name       = aws_config_configuration_recorder.us-west-1.id
  is_enabled = true

  depends_on = [aws_config_delivery_channel.us-west-1]
}

resource "aws_config_delivery_channel" "us-west-1" {
  provider = aws.us-west-1

  name           = var.config_delivery_channels.name
  s3_bucket_name = var.config_delivery_channels.s3_bucket.name
  s3_key_prefix  = var.config_delivery_channels.s3_bucket.key_prefix
  s3_kms_key_arn = var.config_delivery_channels.s3_bucket.sse_kms_key_arn
  sns_topic_arn  = "arn:aws:sns:us-west-1:${local.root_account_id}:${var.config_sns_topics.name}"

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_channel_snapshot_frequency
  }

  depends_on = [aws_config_configuration_recorder.us-west-1]
}

resource "aws_sns_topic" "us-west-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.us-west-1

  name              = var.config_sns_topics.name
  display_name      = var.config_sns_topics.display_name
  kms_master_key_id = var.config_sns_topics.kms_master_key_id
  tags              = var.config_sns_topics.tags
}

resource "aws_sns_topic_policy" "us-west-1" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.us-west-1

  arn = one(aws_sns_topic.us-west-1).arn
  policy = templatefile("${path.module}/templates/Config_SNS_Topic_Policy.json.tftpl", {
    sns_topic_arn   = one(aws_sns_topic.us-west-1).arn
    org_id          = local.org_id
    all_account_ids = local.all_account_ids
  })
}

#---------------------------------------------------------------------
### Config - us-west-2

resource "aws_config_configuration_recorder" "us-west-2" {
  provider = aws.us-west-2

  name     = var.config_recorders.name
  role_arn = var.config_recorders.role_arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = false
  }

  lifecycle {
    /* As of 1/2/22, TF plans constantly showed a diff for the below attribute
    (shows live version has resource_types = []), which is NOT included bc TFR
    docs say it conflicts with recording_group's other 2 attrs, which we use. */
    ignore_changes = [recording_group[0].resource_types]
  }
}

resource "aws_config_configuration_recorder_status" "us-west-2" {
  provider = aws.us-west-2

  name       = aws_config_configuration_recorder.us-west-2.id
  is_enabled = true

  depends_on = [aws_config_delivery_channel.us-west-2]
}

resource "aws_config_delivery_channel" "us-west-2" {
  provider = aws.us-west-2

  name           = var.config_delivery_channels.name
  s3_bucket_name = var.config_delivery_channels.s3_bucket.name
  s3_key_prefix  = var.config_delivery_channels.s3_bucket.key_prefix
  s3_kms_key_arn = var.config_delivery_channels.s3_bucket.sse_kms_key_arn
  sns_topic_arn  = "arn:aws:sns:us-west-2:${local.root_account_id}:${var.config_sns_topics.name}"

  snapshot_delivery_properties {
    delivery_frequency = local.delivery_channel_snapshot_frequency
  }

  depends_on = [aws_config_configuration_recorder.us-west-2]
}

resource "aws_sns_topic" "us-west-2" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.us-west-2

  name              = var.config_sns_topics.name
  display_name      = var.config_sns_topics.display_name
  kms_master_key_id = var.config_sns_topics.kms_master_key_id
  tags              = var.config_sns_topics.tags
}

resource "aws_sns_topic_policy" "us-west-2" {
  count    = local.IS_ROOT_ACCOUNT ? 1 : 0
  provider = aws.us-west-2

  arn = one(aws_sns_topic.us-west-2).arn
  policy = templatefile("${path.module}/templates/Config_SNS_Topic_Policy.json.tftpl", {
    sns_topic_arn   = one(aws_sns_topic.us-west-2).arn
    org_id          = local.org_id
    all_account_ids = local.all_account_ids
  })
}

######################################################################
