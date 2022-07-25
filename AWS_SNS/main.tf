######################################################################
### AWS SNS

resource "aws_sns_topic" "map" {
  for_each = var.sns_topics

  name              = each.key
  display_name      = each.value.display_name
  kms_master_key_id = each.value.kms_master_key_id
  tags              = each.value.tags
}

resource "aws_sns_topic_policy" "map" {
  for_each = aws_sns_topic.map

  arn    = each.value.arn
  policy = var.sns_topics[each.key].policy_json
}

######################################################################
