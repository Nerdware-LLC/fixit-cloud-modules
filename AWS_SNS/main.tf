######################################################################
### AWS SNS

resource "aws_sns_topic" "map" {
  for_each = var.sns_topics

  name              = each.key
  display_name      = each.value.display_name
  kms_master_key_id = each.value.kms_master_key_id
  fifo_topic        = each.value.is_fifo_topic # Default: false
  tags              = each.value.tags

  # Message Delivery Reporting Properties:

  application_failure_feedback_role_arn    = try(each.value.message_delivery_reporting.application.failure_role_arn, null)
  application_success_feedback_role_arn    = try(each.value.message_delivery_reporting.application.success_role_arn, null)
  application_success_feedback_sample_rate = try(each.value.message_delivery_reporting.application.sample_rate, 100)

  http_failure_feedback_role_arn    = try(each.value.message_delivery_reporting.http.failure_role_arn, null)
  http_success_feedback_role_arn    = try(each.value.message_delivery_reporting.http.success_role_arn, null)
  http_success_feedback_sample_rate = try(each.value.message_delivery_reporting.http.sample_rate, 100)

  sqs_failure_feedback_role_arn    = try(each.value.message_delivery_reporting.sqs.failure_role_arn, null)
  sqs_success_feedback_role_arn    = try(each.value.message_delivery_reporting.sqs.success_role_arn, null)
  sqs_success_feedback_sample_rate = try(each.value.message_delivery_reporting.sqs.sample_rate, 100)

  firehose_failure_feedback_role_arn    = try(each.value.message_delivery_reporting.kinesis_firehose.failure_role_arn, null)
  firehose_success_feedback_role_arn    = try(each.value.message_delivery_reporting.kinesis_firehose.success_role_arn, null)
  firehose_success_feedback_sample_rate = try(each.value.message_delivery_reporting.kinesis_firehose.sample_rate, 100)

  lambda_failure_feedback_role_arn    = try(each.value.message_delivery_reporting.lambda.failure_role_arn, null)
  lambda_success_feedback_role_arn    = try(each.value.message_delivery_reporting.lambda.success_role_arn, null)
  lambda_success_feedback_sample_rate = try(each.value.message_delivery_reporting.lambda.sample_rate, 100)
}

#---------------------------------------------------------------------

resource "aws_sns_topic_policy" "map" {
  for_each = aws_sns_topic.map

  arn    = each.value.arn
  policy = data.aws_iam_policy_document.SNS_Topic_Policies[each.key].json
}

data "aws_iam_policy_document" "SNS_Topic_Policies" {
  for_each = var.sns_topics

  dynamic "statement" {
    for_each = each.value.policy_statements

    content {
      sid    = statement.key
      effect = title(statement.value.effect)

      principals {
        type        = statement.value.principals.type
        identifiers = statement.value.principals.identifiers
      }

      actions   = statement.value.actions
      resources = [aws_sns_topic.map[each.key].arn]

      dynamic "condition" {
        for_each = statement.value.conditions != null ? statement.value.conditions : {}

        content {
          test     = condition.key          # IAM condition operator (e.g., "StringEquals", "ArnLike")
          variable = condition.value.key    # IAM condition key (e.g., "aws:username", "aws:SourceArn")
          values   = condition.value.values # IAM condition values (e.g., ["arn:aws:iam::111111111111:role/Foo"])
        }
      }
    }
  }
}

#---------------------------------------------------------------------

resource "aws_sns_topic_subscription" "map" {
  for_each = {
    # Create unique identifier with combination of endpoint+topic
    for sub_config in var.sns_topic_subscriptions : jsonencode({
      endpoint = sub_config.endpoint
      topic    = sub_config.topic
    }) => sub_config
  }

  # Required Properties
  endpoint = each.value.endpoint # delivery destination
  protocol = each.value.protocol # delivery protocol
  topic_arn = (                  # delivery source
    can(aws_sns_topic.map[each.value.topic])
    ? aws_sns_topic.map[each.value.topic].arn # <-- if topic is managed in same module call
    : each.value.topic                        # <-- if topic is the ARN of an external topic
  )

  # Optional Properties
  subscription_role_arn           = each.value.kinesis_delivery_iam_role_arn
  confirmation_timeout_in_minutes = each.value.confirmation_timeout_in_minutes # Default: 1
  delivery_policy                 = each.value.delivery_policy_json
  filter_policy                   = each.value.filter_policy_json
  redrive_policy                  = each.value.redrive_policy_json
  endpoint_auto_confirms          = each.value.endpoint_auto_confirms      # Default: false
  raw_message_delivery            = each.value.enable_raw_message_delivery # Default: false
}

######################################################################
