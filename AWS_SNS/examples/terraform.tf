######################################################################
### EXAMPLE USAGE: AWS_SNS

module "Foo_Key" {
  /* Foo_Key module source and inputs */
}

module "Foo_CloudWatch_Alarms" {
  /* Foo_CloudWatch_Alarms module source and inputs */
}

module "AWS_SNS" {
  source = "git@github.com:Nerdware-LLC/fixit-cloud-modules.git//AWS_SNS"

  sns_topics = {

    CIS_Benchmark_Alarms_SNS_Topic = {
      display_name      = "SNS Topic for CIS AWS Benchmark CloudWatch Alarms"
      kms_master_key_id = module.Foo_Key.KMS_Key.id # not the ARN!
      policy_statements = {
        AllowCloudWatchCISAlarmsSNSPolicy = {
          effect = "Allow"
          principals = {
            type    = "Service"
            Service = "cloudwatch.amazonaws.com"
          }
          actions = ["sns:Publish"]
          conditions = {
            ArnLike = {
              key = "aws:SourceArn"
              values = [
                module.Foo_CloudWatch_Alarms.CloudWatch_Alarms["CIS_AWS_Alarm_a"].arn,
                module.Foo_CloudWatch_Alarms.CloudWatch_Alarms["CIS_AWS_Alarm_b"].arn,
                module.Foo_CloudWatch_Alarms.CloudWatch_Alarms["CIS_AWS_Alarm_c"].arn
              ]
            }
          }
        }
      }
    }
  }
}

######################################################################
