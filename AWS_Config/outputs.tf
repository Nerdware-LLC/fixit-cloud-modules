######################################################################
### OUTPUTS

output "Org_Config_Aggregator" {
  description = "The Config Aggregator resource."
  value       = one(aws_config_configuration_aggregator.list)
}

output "Config_Recorders" {
  description = "A map of AWS-Config Recorders by region."
  value = {
    for region, recorder in {
      "ap-northeast-1" = aws_config_configuration_recorder.ap-northeast-1
      "ap-northeast-2" = aws_config_configuration_recorder.ap-northeast-2
      "ap-northeast-3" = aws_config_configuration_recorder.ap-northeast-3
      "ap-south-1"     = aws_config_configuration_recorder.ap-south-1
      "ap-southeast-1" = aws_config_configuration_recorder.ap-southeast-1
      "ap-southeast-2" = aws_config_configuration_recorder.ap-southeast-2
      "ca-central-1"   = aws_config_configuration_recorder.ca-central-1
      "eu-north-1"     = aws_config_configuration_recorder.eu-north-1
      "eu-central-1"   = aws_config_configuration_recorder.eu-central-1
      "eu-west-1"      = aws_config_configuration_recorder.eu-west-1
      "eu-west-2"      = aws_config_configuration_recorder.eu-west-2
      "eu-west-3"      = aws_config_configuration_recorder.eu-west-3
      "sa-east-1"      = aws_config_configuration_recorder.sa-east-1
      "us-east-1"      = aws_config_configuration_recorder.us-east-1
      "us-east-2"      = aws_config_configuration_recorder.us-east-2
      "us-west-1"      = aws_config_configuration_recorder.us-west-1
      "us-west-2"      = aws_config_configuration_recorder.us-west-2
      } : region => merge(recorder, {
        # The purpose of this block is to kill the erroneous diff msg re: resource_types
        recording_group = [for grp_config in recorder.recording_group : {
          all_supported                 = grp_config.all_supported
          include_global_resource_types = grp_config.include_global_resource_types
        }]
    })
  }
}

output "Config_Delivery_Channels" {
  description = "A map of AWS-Config Delivery Channels by region."
  value = {
    "ap-northeast-1" = aws_config_delivery_channel.ap-northeast-1
    "ap-northeast-2" = aws_config_delivery_channel.ap-northeast-2
    "ap-northeast-3" = aws_config_delivery_channel.ap-northeast-3
    "ap-south-1"     = aws_config_delivery_channel.ap-south-1
    "ap-southeast-1" = aws_config_delivery_channel.ap-southeast-1
    "ap-southeast-2" = aws_config_delivery_channel.ap-southeast-2
    "ca-central-1"   = aws_config_delivery_channel.ca-central-1
    "eu-north-1"     = aws_config_delivery_channel.eu-north-1
    "eu-central-1"   = aws_config_delivery_channel.eu-central-1
    "eu-west-1"      = aws_config_delivery_channel.eu-west-1
    "eu-west-2"      = aws_config_delivery_channel.eu-west-2
    "eu-west-3"      = aws_config_delivery_channel.eu-west-3
    "sa-east-1"      = aws_config_delivery_channel.sa-east-1
    "us-east-1"      = aws_config_delivery_channel.us-east-1
    "us-east-2"      = aws_config_delivery_channel.us-east-2
    "us-west-1"      = aws_config_delivery_channel.us-west-1
    "us-west-2"      = aws_config_delivery_channel.us-west-2
  }
}

output "Org_Config_SNS_Topics" {
  description = "A map of AWS-Config SNS Topics by region (will be \"null\" for non-root accounts)."
  value = (local.IS_ROOT_ACCOUNT == false
    ? null
    : {
      "ap-northeast-1" = one(aws_sns_topic.ap-northeast-1)
      "ap-northeast-2" = one(aws_sns_topic.ap-northeast-2)
      "ap-northeast-3" = one(aws_sns_topic.ap-northeast-3)
      "ap-south-1"     = one(aws_sns_topic.ap-south-1)
      "ap-southeast-1" = one(aws_sns_topic.ap-southeast-1)
      "ap-southeast-2" = one(aws_sns_topic.ap-southeast-2)
      "ca-central-1"   = one(aws_sns_topic.ca-central-1)
      "eu-north-1"     = one(aws_sns_topic.eu-north-1)
      "eu-central-1"   = one(aws_sns_topic.eu-central-1)
      "eu-west-1"      = one(aws_sns_topic.eu-west-1)
      "eu-west-2"      = one(aws_sns_topic.eu-west-2)
      "eu-west-3"      = one(aws_sns_topic.eu-west-3)
      "sa-east-1"      = one(aws_sns_topic.sa-east-1)
      "us-east-1"      = one(aws_sns_topic.us-east-1)
      "us-east-2"      = one(aws_sns_topic.us-east-2)
      "us-west-1"      = one(aws_sns_topic.us-west-1)
      "us-west-2"      = one(aws_sns_topic.us-west-2)
    }
  )
}

######################################################################
