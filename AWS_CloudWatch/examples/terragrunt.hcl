######################################################################
### EXAMPLE USAGE: AWS_CloudWatch

/* As in any Terragrunt configuration, the inputs below can be
provided in a single standalone resource config, or may be broken up
across multiple resource configs and utilized with a combination of
include-blocks and/or the read_terragrunt_config() Terragrunt fn. */

#---------------------------------------------------------------------
### Dependencies

dependency "CloudTrail_KMS_Key" {
  config_path = "${get_terragrunt_dir()}/../CloudTrail_KMS_Key"
}

dependency "CloudWatch_Alarm_SNS_Topic" {
  config_path = "${get_terragrunt_dir()}/../CloudWatch_Alarm_SNS_Topic"
}

dependency "EC2_Instance" {
  config_path = "${get_terragrunt_dir()}/../EC2_Instance"
}

#---------------------------------------------------------------------
### Inputs

inputs = {

  cloudwatch_logs_log_groups = {
    "Org_CloudTrail/Security/us-west-1" = {
      retention_in_days = 400
      kms_key_arn       = dependency.CloudTrail_KMS_Key.outputs.KMS_Key.arn
    }
  }

  #-------------------------------------------------------------------

  cloudwatch_log_metric_filters = {
    UnauthorizedAPICalls = {
      log_group_name = "Org_CloudTrail/Security/us-west-1"
      pattern        = "{ (( $.errorCode = \"*UnauthorizedOperation\" ) || ( $.errorCode = \"AccessDenied*\" )) && (( $.sourceIPAddress != \"delivery.logs.amazonaws.com\" ) && ( $.eventName != \"HeadBucket\" )) }"
      metric_transformation = object({
        namespace     = "CIS_Benchmarks"
        name          = "UnauthorizedAPICalls"
        value         = "1"
        default_value = "0"
      })
    }
  }

  #-------------------------------------------------------------------

  cloudwatch_metric_alarms = {

    # Alarm with a static metric:
    UnauthorizedAPICalls = {
      description = "Monitoring unauthorized API calls will help reveal application errors and may reduce time to detect malicious activity."
      static_metric = {
        namespace = "CIS_Benchmarks"
        name      = "UnauthorizedAPICalls"
        statistic = "Sum"
        period    = "300"
        threshold = "1"
      }
      comparison_operator = "GreaterThanOrEqualToThreshold"
      evaluation_periods  = "1"
      treat_missing_data  = "notBreaching"
      alarm_action_arns   = [dependency.CloudWatch_Alarm_SNS_Topic.outputs.Topic.arn]
    }

    # Alarm with a sequence of metric queries:
    ELB_Error_Rate = {
      description = "Request error rate has exceeded 10%."
      metric_queries = {
        e1 = {
          expression           = "m2/m1*100" # <-- Note how m1 and m2 are used here
          label                = "Error Rate"
          return_data          = true
          use_to_set_threshold = true
        }
        m1 = {
          metric = {
            namespace = "AWS/ApplicationELB"
            name      = "RequestCount"
            statistic = "Sum"
            period    = "120"
            unit      = "Count"
            dimensions = {
              LoadBalancer = "app/web"
            }
          }
        }
        m2 = {
          metric = {
            namespace = "AWS/ApplicationELB"
            name      = "HTTPCode_ELB_5XX_Count"
            statistic = "Sum"
            period    = "120"
            unit      = "Count"
            dimensions = {
              LoadBalancer = "app/web"
            }
          }
        }
      }
      comparison_operator = "GreaterThanOrEqualToThreshold"
      evaluation_periods  = "2"
      alarm_action_arns   = [dependency.CloudWatch_Alarm_SNS_Topic.outputs.Topic.arn]
    }

    # Alarm which uses an anomaly detection model:
    ELB_Error_Rate = {
      description = "This metric monitors ec2 cpu utilization."
      metric_queries = {
        e1 = {
          expression           = "ANOMALY_DETECTION_BAND(m1)"
          label                = "CPUUtilization (Expected)"
          return_data          = true
          use_to_set_threshold = true
        }
        m1 = {
          return_data = true
          metric = {
            namespace = "AWS/EC2"
            name      = "CPUUtilization"
            statistic = "Average"
            period    = "120"
            unit      = "Count"
            dimensions = {
              InstanceId = "i-abc123"
            }
          }
        }
      }
      comparison_operator = "GreaterThanUpperThreshold"
      evaluation_periods  = "2"
      alarm_action_arns   = [dependency.CloudWatch_Alarm_SNS_Topic.outputs.Topic.arn]
    }
  }

  #-------------------------------------------------------------------

  cloudwatch_dashboards = {
    My_Good_Dashboard = jsonencode({
      widgets = [
        {
          type   = "metric"
          x      = 0
          y      = 0
          width  = 12
          height = 6
          properties = {
            metrics = [
              ["AWS/EC2", "CPUUtilization", "InstanceId", dependency.EC2_Instance.outputs.InstanceId]
            ]
            period = 300
            stat   = "Average"
            region = "us-west-1"
            title  = "EC2 Instance CPU"
          }
        },
        {
          type   = "text"
          x      = 0
          y      = 7
          width  = 3
          height = 3
          properties = {
            markdown = "Hello world"
          }
        }
      ]
    })
  }
}

######################################################################
