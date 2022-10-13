######################################################################
### Account Password Policy

# TFsec rule ignored since var validation ensures user can only provide "stricter" values.
# tfsec:ignore:aws-iam-set-minimum-password-length
resource "aws_iam_account_password_policy" "this" {
  max_password_age               = var.iam_account_password_policy.max_password_age          # CIS AWS 1.3  (v1.4)
  require_uppercase_characters   = true                                                      # CIS AWS 1.5  (v1.4)
  require_lowercase_characters   = true                                                      # CIS AWS 1.6  (v1.4)
  require_symbols                = true                                                      # CIS AWS 1.7  (v1.4)
  require_numbers                = true                                                      # CIS AWS 1.8  (v1.4)
  minimum_password_length        = var.iam_account_password_policy.min_password_length       # CIS AWS 1.9  (v1.4)
  password_reuse_prevention      = var.iam_account_password_policy.password_reuse_prevention # CIS AWS 1.10 (v1.4)
  hard_expiry                    = true
  allow_users_to_change_password = true
}

#---------------------------------------------------------------------
### EBS Encryption

resource "aws_ebs_encryption_by_default" "this" {
  enabled = true
}

#---------------------------------------------------------------------
### Account-Level S3 Public Access Rules

# Setting these all to true accomplishes AWS FSBP [S3.1] S3 Block Public Access setting should be enabled
resource "aws_s3_account_public_access_block" "this" {
  block_public_acls       = true # PUT calls fail if req includes a public ACL
  block_public_policy     = true # PUT calls fail if bucket policy allows public access
  ignore_public_acls      = true # Ignore all public ACLs on buckets/objects in this account
  restrict_public_buckets = true # Only the bucket owner and AWS Services can access buckets with public policies
}

######################################################################
