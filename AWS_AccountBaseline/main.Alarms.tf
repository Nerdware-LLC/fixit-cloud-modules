######################################################################
### CloudWatch Alarms

/* NOTE: CloudWatch Alarms are strictly REGIONAL; you can't create an
alarm in one Region that watches a metric in a different Region.  */

resource "aws_cloudwatch_metric_alarm" "map" {
  for_each = aws_cloudwatch_log_metric_filter.map

  namespace         = var.cloudwatch_alarms.namespace
  metric_name       = each.value.id
  alarm_name        = each.key
  alarm_description = local.LOG_METRICS[each.key].alarm_description
  alarm_actions     = [one(aws_sns_topic.CloudWatch_Alarms).arn]

  comparison_operator       = "GreaterThanOrEqualToThreshold"
  statistic                 = "Sum"
  threshold                 = "1"
  period                    = "300"
  evaluation_periods        = "1"
  treat_missing_data        = "notBreaching"
  insufficient_data_actions = []
  tags                      = { Name = "${each.key}_CloudWatch_Metric_Alarm" }
}

resource "aws_cloudwatch_log_metric_filter" "map" {
  for_each = local.IS_LOG_ARCHIVE_ACCOUNT ? local.LOG_METRICS : {}

  name           = each.key
  pattern        = each.value.filter_pattern
  log_group_name = var.org_cloudtrail.cloudwatch_config.log_group.name

  metric_transformation {
    name      = each.key
    namespace = var.cloudwatch_alarms.namespace
    value     = "1" # "1" = count each occurrence of the keywords in the filter
  }
}

#---------------------------------------------------------------------
# The SNS Topic to which CloudWatch Alarms send events

resource "aws_sns_topic" "CloudWatch_Alarms" {
  count = local.IS_LOG_ARCHIVE_ACCOUNT ? 1 : 0

  name              = var.cloudwatch_alarms.sns_topic.name
  display_name      = var.cloudwatch_alarms.sns_topic.display_name
  kms_master_key_id = local.org_kms_key_alias
  tags              = var.cloudwatch_alarms.sns_topic.tags
}

resource "aws_sns_topic_policy" "CloudWatch_Alarms" {
  count = local.IS_LOG_ARCHIVE_ACCOUNT ? 1 : 0

  arn    = one(aws_sns_topic.CloudWatch_Alarms).arn
  policy = one(data.aws_iam_policy_document.CloudWatch_Alarms_SNS_Policy).json
}

data "aws_iam_policy_document" "CloudWatch_Alarms_SNS_Policy" {
  count = local.IS_LOG_ARCHIVE_ACCOUNT ? 1 : 0

  statement {
    actions   = ["sns:Publish"]
    resources = [one(aws_sns_topic.CloudWatch_Alarms).arn]

    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }

    condition {
      test     = "ArnLike"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:cloudwatch:${local.aws_region}:${var.log_archive_account_id}:alarm:*"]
    }
  }
}

#---------------------------------------------------------------------
# CloudWatch metrics and alarms defined in the CIS benchmark.

locals {
  LOG_METRICS = {
    UnauthorizedAPICalls = {
      alarm_description = "Monitoring unauthorized API calls will help reveal application errors and may reduce time to detect malicious activity."
      filter_pattern    = "{ (($.errorCode = \"*UnauthorizedOperation\") || ( $.errorCode = \"AccessDenied*\" )) && (( $.sourceIPAddress != \"delivery.logs.amazonaws.com\" ) && ( $.eventName != \"HeadBucket\" )) }"
    }
    NoMFAConsoleSignin = {
      alarm_description = "Monitoring for single-factor console logins will increase visibility into accounts that are not protected by MFA."
      filter_pattern    = "{ ( $.eventName = \"ConsoleLogin\" ) && ( $.additionalEventData.MFAUsed != \"Yes\" ) && ( $.userIdentity.type = \"IAMUser\" ) && ( $.responseElements.ConsoleLogin = \"Success\" ) }"
    }
    RootUsage = {
      alarm_description = "Monitoring for root account logins will provide visibility into the use of a fully privileged account and an opportunity to reduce the use of it."
      filter_pattern    = "{ $.userIdentity.type = \"Root\" && $.userIdentity.invokedBy NOT EXISTS && $.eventType != \"AwsServiceEvent\" }"
    }
    IAMChanges = {
      alarm_description = "Monitoring changes to IAM policies will help ensure authentication and authorization controls remain intact."
      filter_pattern    = "{ ( $.eventName = DeleteGroupPolicy ) || ( $.eventName = DeleteRolePolicy ) || ( $.eventName = DeleteUserPolicy ) || ( $.eventName = PutGroupPolicy ) || ( $.eventName = PutRolePolicy ) || ( $.eventName = PutUserPolicy ) || ( $.eventName = CreatePolicy ) || ( $.eventName = DeletePolicy ) || ( $.eventName = CreatePolicyVersion ) || ( $.eventName = DeletePolicyVersion ) || ( $.eventName = AttachRolePolicy ) || ( $.eventName = DetachRolePolicy ) || ( $.eventName = AttachUserPolicy ) || ( $.eventName = DetachUserPolicy ) || ( $.eventName = AttachGroupPolicy ) || ( $.eventName = DetachGroupPolicy ) }"
    }
    CloudTrailCfgChanges = {
      alarm_description = "Monitoring changes to CloudTrail's configuration will help ensure sustained visibility to activities performed in the AWS account."
      filter_pattern    = "{ ( $.eventName = CreateTrail ) || ( $.eventName = UpdateTrail ) || ( $.eventName = DeleteTrail ) || ( $.eventName = StartLogging ) || ( $.eventName = StopLogging ) }"
    }
    ConsoleSigninFailures = {
      alarm_description = "Monitoring failed console logins may decrease lead time to detect an attempt to brute force a credential, which may provide an indicator, such as source IP, that can be used in other event correlation."
      filter_pattern    = "{ ( $.eventName = ConsoleLogin ) && ( $.errorMessage = \"Failed authentication\") }"
    }
    DisableOrDeleteCMK = {
      alarm_description = "Monitoring failed console logins may decrease lead time to detect an attempt to brute force a credential, which may provide an indicator, such as source IP, that can be used in other event correlation."
      filter_pattern    = "{ ( $.eventSource = kms.amazonaws.com ) && (( $.eventName = DisableKey ) || ( $.eventName = ScheduleKeyDeletion )) }"
    }
    S3BucketPolicyChanges = {
      alarm_description = "Monitoring changes to S3 bucket policies may reduce time to detect and correct permissive policies on sensitive S3 buckets."
      filter_pattern    = "{ ( $.eventSource = s3.amazonaws.com ) && (( $.eventName = PutBucketAcl ) || ( $.eventName = PutBucketPolicy ) || ( $.eventName = PutBucketCors ) || ( $.eventName = PutBucketLifecycle ) || ( $.eventName = PutBucketReplication ) || ( $.eventName = DeleteBucketPolicy ) || ( $.eventName = DeleteBucketCors ) || ( $.eventName = DeleteBucketLifecycle ) || ( $.eventName = DeleteBucketReplication )) }"
    }
    AWSConfigChanges = {
      alarm_description = "Monitoring changes to AWS Config configuration will help ensure sustained visibility of configuration items within the AWS account."
      filter_pattern    = "{ ( $.eventSource = config.amazonaws.com ) && (( $.eventName = StopConfigurationRecorder ) || ( $.eventName = DeleteDeliveryChannel ) || ( $.eventName = PutDeliveryChannel ) || ( $.eventName = PutConfigurationRecorder )) }"
    }
    SecurityGroupChanges = {
      alarm_description = "Monitoring changes to security group will help ensure that resources and services are not unintentionally exposed."
      filter_pattern    = "{ ( $.eventName = AuthorizeSecurityGroupIngress ) || ( $.eventName = AuthorizeSecurityGroupEgress ) || ( $.eventName = RevokeSecurityGroupIngress ) || ( $.eventName = RevokeSecurityGroupEgress ) || ( $.eventName = CreateSecurityGroup ) || ( $.eventName = DeleteSecurityGroup ) }"
    }
    NACLChanges = {
      alarm_description = "Monitoring changes to NACLs will help ensure that AWS resources and services are not unintentionally exposed."
      filter_pattern    = "{ ( $.eventName = CreateNetworkAcl ) || ( $.eventName = CreateNetworkAclEntry ) || ( $.eventName = DeleteNetworkAcl ) || ( $.eventName = DeleteNetworkAclEntry ) || ( $.eventName = ReplaceNetworkAclEntry ) || ( $.eventName = ReplaceNetworkAclAssociation ) }"
    }
    NetworkGWChanges = {
      alarm_description = "Monitoring changes to network gateways will help ensure that all ingress/egress traffic traverses the VPC border via a controlled path."
      filter_pattern    = "{ ( $.eventName = CreateCustomerGateway ) || ( $.eventName = DeleteCustomerGateway ) || ( $.eventName = AttachInternetGateway ) || ( $.eventName = CreateInternetGateway ) || ( $.eventName = DeleteInternetGateway ) || ( $.eventName = DetachInternetGateway ) }"
    }
    RouteTableChanges = {
      alarm_description = "Monitoring changes to route tables will help ensure that all VPC traffic flows through an expected path."
      filter_pattern    = "{ ( $.eventName = CreateRoute ) || ( $.eventName = CreateRouteTable ) || ( $.eventName = ReplaceRoute ) || ( $.eventName = ReplaceRouteTableAssociation ) || ( $.eventName = DeleteRouteTable ) || ( $.eventName = DeleteRoute ) || ( $.eventName = DisassociateRouteTable ) }"
    }
    VPCChanges = {
      alarm_description = "Monitoring changes to VPC will help ensure that all VPC traffic flows through an expected path."
      filter_pattern    = "{ ( $.eventName = CreateVpc ) || ( $.eventName = DeleteVpc ) || ( $.eventName = ModifyVpcAttribute ) || ( $.eventName = AcceptVpcPeeringConnection ) || ( $.eventName = CreateVpcPeeringConnection ) || ( $.eventName = DeleteVpcPeeringConnection ) || ( $.eventName = RejectVpcPeeringConnection ) || ( $.eventName = AttachClassicLinkVpc ) || ( $.eventName = DetachClassicLinkVpc ) || ( $.eventName = DisableVpcClassicLink ) || ( $.eventName = EnableVpcClassicLink ) }"
    }
    OrganizationsChanges = {
      alarm_description = "Monitoring AWS Organizations changes can help you prevent any unwanted, accidental or intentional modifications that may lead to unauthorized access or other security breaches."
      filter_pattern    = "{ ( $.eventSource = organizations.amazonaws.com ) && (( $.eventName = \"AcceptHandshake\" ) || ( $.eventName = \"AttachPolicy\" ) || ( $.eventName = \"CreateAccount\" ) || ( $.eventName = \"CreateOrganizationalUnit\" ) || ( $.eventName= \"CreatePolicy\" ) || ( $.eventName = \"DeclineHandshake\" ) || ( $.eventName = \"DeleteOrganization\" ) || ( $.eventName = \"DeleteOrganizationalUnit\" ) || ( $.eventName = \"DeletePolicy\" ) || ( $.eventName = \"DetachPolicy\" ) || ( $.eventName = \"DisablePolicyType\" ) || ( $.eventName = \"EnablePolicyType\" ) || ( $.eventName = \"InviteAccountToOrganization\" ) || ( $.eventName = \"LeaveOrganization\" ) || ( $.eventName = \"MoveAccount\" ) || ( $.eventName = \"RemoveAccountFromOrganization\" ) || ( $.eventName = \"UpdatePolicy\" ) || ( $.eventName = \"UpdateOrganizationalUnit\" )) }"
    }
  }
}

######################################################################