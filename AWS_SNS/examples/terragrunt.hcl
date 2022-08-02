######################################################################
### EXAMPLE USAGE: AWS_SNS

/* As in any Terragrunt configuration, the inputs below can be
provided in a single standalone resource config, or may be broken up
across multiple resource configs and utilized with a combination of
include-blocks and/or the read_terragrunt_config() Terragrunt fn. */

#---------------------------------------------------------------------
### Dependencies

dependency "Foo_Key" {
  config_path = "${get_terragrunt_dir()}/../Foo_KMS_Key"
}

dependency "Foo_CloudWatch_Alarms" {
  config_path = "${get_terragrunt_dir()}/../CloudWatch"
}

#---------------------------------------------------------------------
### Inputs

inputs = {

  sns_topics = {

    CIS_Benchmark_Alarms_SNS_Topic = {
      display_name      = "SNS Topic for CIS AWS Benchmark CloudWatch Alarms"
      kms_master_key_id = dependency.Foo_Key.outputs.KMS_Key.id # not the ARN!
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
                dependency.Foo_CloudWatch_Alarms.outputs.CloudWatch_Alarms["CIS_AWS_Alarm_a"].arn,
                dependency.Foo_CloudWatch_Alarms.outputs.CloudWatch_Alarms["CIS_AWS_Alarm_b"].arn,
                dependency.Foo_CloudWatch_Alarms.outputs.CloudWatch_Alarms["CIS_AWS_Alarm_c"].arn
              ]
            }
          }
        }
      }
    }
  }
}

######################################################################
