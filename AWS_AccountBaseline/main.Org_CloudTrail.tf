######################################################################
### CloudTrail

resource "aws_cloudtrail" "Org_CloudTrail" {
  count = local.IS_ROOT_ACCOUNT ? 1 : 0

  name = var.org_cloudtrail.name

  is_organization_trail         = true
  include_global_service_events = true # global services like IAM
  is_multi_region_trail         = true

  # Logging Config
  s3_bucket_name = var.org_cloudtrail_s3_bucket.name
  # TODO As of 12/6/21, this rule always err's out. Rm the 'ignore' directive once they fix it.
  #tfsec:ignore:aws-cloudtrail-enable-at-rest-encryption
  kms_key_id                 = one(aws_kms_key.Org_CloudTrail_KMS_Key).arn
  enable_log_file_validation = true

  # CloudTrail requires the Log Stream wildcard as shown below
  cloud_watch_logs_group_arn = "${one(aws_cloudwatch_log_group.CloudTrail_Events).arn}:*"
  cloud_watch_logs_role_arn  = one(aws_iam_role.CloudWatch-Delivery_Role).arn

  # TODO maybe turn the below item on
  # sns_topic_name = aws_sns_topic.cloudtrail-sns-topic[0].arn

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }

  insight_selector {
    insight_type = "ApiCallRateInsight"
  }

  tags = var.org_cloudtrail.tags
}

######################################################################
