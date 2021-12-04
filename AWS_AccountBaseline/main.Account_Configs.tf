######################################################################
### Account Password Policy

resource "aws_iam_account_password_policy" "Account_PW_Policy" {
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

resource "aws_ebs_encryption_by_default" "Global_EBS_Encyption" {
  enabled = true
}

######################################################################
