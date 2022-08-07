######################################################################
### EXAMPLE USAGE: AWS_S3

/* As in any Terragrunt configuration, the inputs below can be
provided in a single standalone resource config, or may be broken up
across multiple resource configs and utilized with a combination of
include-blocks and/or the read_terragrunt_config() Terragrunt fn. */

#---------------------------------------------------------------------
### Module Dependencies

dependency "S3_SSE_KMS_Key" {
  config_path = "${get_terragrunt_dir()}/../S3_SSE_KMS_Key"
}

dependency "AWS_IAM" {
  config_path = "${get_terragrunt_dir()}/../AWS_IAM"
}

dependency "AWS_Organization" {
  config_path = "${get_terragrunt_dir()}/../AWS_Organization"
}

#---------------------------------------------------------------------
### Inputs

locals {
  bucket_name = "foo-bucket"
}

inputs = {

  bucket_name = local.bucket_name
  bucket_tags = { Name = local.bucket_name }

  bucket_policy = jsonencode({
    Id      = "FooBucketPolicy"
    Version = "2012-10-17"
    Statement = {
      Sid    = "AllowAdminUserActions"
      Effect = "Allow"
      Principal = {
        AWS = dependency.AWS_IAM.outputs.IAM_Roles["OrganizationAccountFooAdminAccessRole"].arn
      }
      Action = "s3:*"
      Resource = [
        "arn:aws:s3:::${local.bucket_name}",
        "arn:aws:s3:::${local.bucket_name}/*"
      ]
      Condition = {
        StringEquals = {
          "aws:PrincipalOrgID" = dependency.AWS_Organization.outputs.Organization.id
        }
      }
    }
  })

  sse_kms_config = {
    key_arn                  = dependency.S3_SSE_KMS_Key.outputs.KMS_Key.arn
    should_enable_bucket_key = true
  }

  access_logs_config = {
    bucket_name = "access-logs-bucket-for-foo-bucket"
  }

  lifecycle_rules = {
    # FIXED RULE 1, Auto-Archive
    auto-archive = {
      transition = {
        storage_class = "GLACIER_IR"
        days          = 30 # after 30 days, transfer everything to Glacier-IR
      }
      noncurrent_version_transition = {
        storage_class             = "GLACIER_IR"
        newer_noncurrent_versions = 1 # transfer old versions to Glacier-IR
      }
      noncurrent_version_expiration = {
        newer_noncurrent_versions = 3   # don't keep more than 3 versions
        noncurrent_days           = 100 # AWS will permanently delete expired versions after 100 days
      }
    }
    /* Multipart Uploads:
      To minimize cloud-spend waste, this rule automatically aborts incomplete multipart
      uploads after 7 days, thereby eliminating costs which would otherwise be incurred
      due to the accrual of incomplete MPU parts which aren't properly aborted/removed.
    */
    auto-delete-failed-multipart-uploads-7days = {
      abort_incomplete_multipart_upload = {
        days_after_initiation = 7
      }
    }
  }
}

# TODO Add Terragrunt usage examples for S3 replication and website hosting w/ CORS.

######################################################################
