######################################################################
### Account Password Policy

resource "aws_iam_account_password_policy" "this" {
  # Password complexity settings:
  minimum_password_length      = 14
  require_lowercase_characters = true
  require_uppercase_characters = true
  require_numbers              = true
  require_symbols              = true
  # Settings that control HOW/WHEN passwords are reset:
  max_password_age               = 90
  password_reuse_prevention      = 5
  allow_users_to_change_password = true
  hard_expiry                    = false # Admin-only reset after expiry.
}

#---------------------------------------------------------------------
### EBS Encryption

resource "aws_ebs_encryption_by_default" "this" {
  enabled = true
}

#---------------------------------------------------------------------
### Account-Level S3 Public Access Rules

# Docs => https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_account_public_access_block

resource "aws_s3_account_public_access_block" "this" {
  account_id              = local.caller_account_id
  block_public_acls       = coalesce(var.s3_public_access_blocks.block_public_acls, true) # PUT calls fail if req includes a public ACL
  block_public_policy     = coalesce(var.s3_public_access_blocks.block_public_acls, true) # PUT calls fail if bucket policy allows public access
  ignore_public_acls      = coalesce(var.s3_public_access_blocks.block_public_acls, true) # Ignore all public ACLs on buckets/objects in this account
  restrict_public_buckets = coalesce(var.s3_public_access_blocks.block_public_acls, true) # Only the bucket owner and AWS Services can access buckets with public policies
}

######################################################################
