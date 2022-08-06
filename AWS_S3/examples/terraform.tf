######################################################################
### EXAMPLE USAGE: AWS_S3

module "S3_SSE_KMS_Key" {
  /* module inputs */
}

module "AWS_IAM" {
  /* module inputs */
}

module "AWS_Organization" {
  /* module inputs */
}

locals {
  bucket_name = "foo-bucket"
}

module "AWS_S3" {
  source = "git@github.com:Nerdware-LLC/fixit-cloud-modules.git//AWS_S3"

  bucket_name = local.bucket_name
  bucket_tags = { Name = local.bucket_name }

  bucket_policy = jsonencode({
    Id      = "FooBucketPolicy"
    Version = "2012-10-17"
    Statement = {
      Sid    = "AllowAdminUserActions"
      Effect = "Allow"
      Principal = {
        AWS = module.AWS_IAM.IAM_Roles["OrganizationAccountFooAdminAccessRole"].arn
      }
      Action = "s3:*"
      Resource = [
        "arn:aws:s3:::${local.bucket_name}",
        "arn:aws:s3:::${local.bucket_name}/*"
      ]
      Condition = {
        StringEquals = {
          "aws:PrincipalOrgID" = module.AWS_Organization.Organization.id
        }
      }
    }
  })

  sse_kms_config = {
    key_arn                  = module.S3_SSE_KMS_Key.KMS_Key.arn
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
        newer_noncurrent_versions = 3 # don't keep more than 3 versions
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

# TODO Add Terraform usage examples for S3 replication and website hosting w/ CORS.

######################################################################
