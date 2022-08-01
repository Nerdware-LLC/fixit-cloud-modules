######################################################################
### EXAMPLE USAGE: AWS_CloudTrail

/* As in any Terragrunt configuration, the inputs below can be
provided in a single standalone resource config, or may be broken up
across multiple resource configs and utilized with a combination of
include-blocks and/or the read_terragrunt_config() Terragrunt fn. */

#---------------------------------------------------------------------
### Dependencies

dependency "CloudTrail_Bucket" {
  config_path = "${get_terragrunt_dir()}/../CloudTrail_Bucket"
}

dependency "CloudTrail_CloudWatch_Logs" {
  config_path = "${get_terragrunt_dir()}/../CloudTrail_CloudWatch_Logs"
}

dependency "AWS_IAM" {
  config_path = "${get_terragrunt_dir()}/../AWS_IAM"
}

#---------------------------------------------------------------------
### Inputs

inputs = {
  trail_name = "My_CloudTrail"

  is_organization_trail         = true
  include_global_service_events = true

  logging_config = {
    s3_bucket_name  = dependency.CloudTrail_Bucket.outputs.Bucket.name
    sse_kms_key_arn = dependency.CloudTrail_Bucket.outputs.SSE_KMS_Key.arn
  }

  cloud_watch_logs_config = {
    log_group_arn = dependency.CloudTrail_CloudWatch_Logs.outputs.Log_Group.arn
    log_group_arn = dependency.AWS_IAM.outputs.Roles["CloudTrail_CloudWatch_Delivery_Role"].arn
  }

  trail_tags = {
    Name                  = "My_CloudTrail"
    is_a_good_cloud_trail = "indeed it is"
  }
}

######################################################################
