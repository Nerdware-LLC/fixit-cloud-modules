######################################################################
### EXAMPLE USAGE: AWS_CloudTrail

module "CloudTrail_Bucket" {
  /* dependency inputs */
}

module "CloudTrail_CloudWatch_Logs" {
  /* dependency inputs */
}

module "AWS_IAM" {
  /* dependency inputs */
}

module "AWS_CloudTrail" {
  source = "git@github.com:Nerdware-LLC/fixit-cloud-modules.git//AWS_CloudTrail"

  trail_name = "My_CloudTrail"

  is_organization_trail         = true
  is_multi_region_trail         = true
  include_global_service_events = true

  logging_config = {
    s3_bucket_name  = module.CloudTrail_Bucket.Bucket.name
    sse_kms_key_arn = module.CloudTrail_Bucket.SSE_KMS_Key.arn
  }

  cloud_watch_logs_config = {
    log_group_arn = module.CloudTrail_CloudWatch_Logs.Log_Group.arn
    log_group_arn = module.AWS_IAM.Roles["CloudTrail_CloudWatch_Delivery_Role"].arn
  }

  trail_tags = {
    Name                  = "My_CloudTrail"
    is_a_good_cloud_trail = "indeed it is"
  }
}

######################################################################
