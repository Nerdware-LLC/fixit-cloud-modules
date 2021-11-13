##################################################
### Account Password Policy

resource "aws_iam_account_password_policy" "Account_PW_Policy" {
  minimum_password_length        = 8 # TODO CIS recommends 14
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true
}

#--------------------------------------------------
### EBS Encryption

resource "aws_ebs_encryption_by_default" "Global_EBS_Encyption" {
  enabled = true
}

##################################################
