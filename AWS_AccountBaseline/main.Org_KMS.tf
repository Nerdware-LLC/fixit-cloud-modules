######################################################################
### Organization Services KMS Key

resource "aws_kms_key" "Org_KMS_Key" {
  count = local.IS_ROOT_ACCOUNT ? 1 : 0

  description = coalesce(
    var.org_kms_key.description,
    "A KMS key to encrypt Log-Archive files, as well as data streams for services like CloudTrail, CloudWatch, and SNS."
  )
  policy              = one(data.aws_iam_policy_document.Org_KMS_Key_Policy).json
  multi_region        = true
  enable_key_rotation = true
  tags                = var.org_kms_key.tags
}

#---------------------------------------------------------------------
### Org Services KMS Key ALIAS

locals {
  org_kms_key_alias = "alias/${var.org_kms_key.alias_name}"
}

/* The key's alias makes it easier for the Log-Archive account to use
the key (necessary for CloudWatch Logs and S3 log bucket encryption) */
resource "aws_kms_alias" "Org_KMS_Key" {
  count = local.IS_ROOT_ACCOUNT ? 1 : 0

  name          = local.org_kms_key_alias
  target_key_id = one(aws_kms_key.Org_KMS_Key).key_id
}

#---------------------------------------------------------------------
### Org Services KMS Key POLICY

# NOTE: in KMS key policies, all 'resource' values must = "*" (points to the key itself)

data "aws_iam_policy_document" "Org_KMS_Key_Policy" {
  count = local.IS_ROOT_ACCOUNT ? 1 : 0

  policy_id = var.org_kms_key.key_policy_id

  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [local.root_account_id, var.log_archive_account_id]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "Allow CloudTrail to encrypt logs with this key"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["kms:GenerateDataKey*"]
    resources = ["*"]
    condition {
      test     = "ArnLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:aws:cloudtrail:*:${local.root_account_id}:trail/*"]
    }
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = ["arn:aws:cloudtrail:${local.aws_region}:${local.root_account_id}:trail/${var.org_cloudtrail.name}"]
    }
  }

  statement {
    sid    = "Allow CloudTrail to describe key"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["kms:DescribeKey"]
    resources = ["*"]
  }

  statement {
    sid    = "Allow principals in the account to decrypt log files"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["kms:Decrypt", "kms:ReEncryptFrom"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [local.root_account_id, var.log_archive_account_id]
    }
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:aws:cloudtrail:*:${local.root_account_id}:trail/*"]
    }
  }

  statement {
    sid    = "Allow alias creation during setup"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["kms:CreateAlias"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["ec2.${local.aws_region}.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [local.root_account_id, var.log_archive_account_id]
    }
  }

  statement {
    sid    = "Enable cross account log decryption"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["kms:Decrypt", "kms:ReEncryptFrom"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [local.root_account_id, var.log_archive_account_id]
    }
    condition {
      test     = "StringLikeIfExists"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:aws:cloudtrail:*:${local.root_account_id}:trail/*"]
    }
  }

  # CloudWatch Log Group:
  statement {
    sid    = "CloudWatch_KMS_Policy"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["logs.${local.aws_region}.amazonaws.com"]
    }
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    resources = ["*"]
    condition {
      test     = "ArnEquals"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values   = ["arn:aws:logs:${local.aws_region}:${local.root_account_id}:log-group:${local.cw_log_grp.name}"]
    }
  }

  # AWS-Config:
  statement {
    sid    = "AWS-Config_KMS_Policy"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions   = ["kms:Decrypt", "kms:GenerateDataKey*"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalOrgID"
      values   = [local.org_id]
    }
  }
}

######################################################################
