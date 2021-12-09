######################################################################
### Org CloudTrail KMS Key

resource "aws_kms_key" "Org_CloudTrail_KMS_Key" {
  count = local.IS_ROOT_ACCOUNT ? 1 : 0

  description         = "A KMS key to encrypt Org_CloudTrail events."
  policy              = data.aws_iam_policy_document.Org_CloudTrail_KMS_Key.json
  enable_key_rotation = true
  tags = {
    Name = "Org_CloudTrail_KMS_Key"
  }
}

locals {
  # TODO Below change was made to fix circular dep issue; update key policy later.
  # resources = ["arn:aws:kms:${local.aws_region}:${local.root_account_id}:key/${aws_kms_key.Org_CloudTrail_KMS_Key.id}"]
  kms_key_resource = "arn:aws:kms:${local.aws_region}:${local.root_account_id}:key/*"
}

data "aws_iam_policy_document" "Org_CloudTrail_KMS_Key" {
  policy_id = "Key policy created for Org_CloudTrail_KMS_Key"

  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        local.root_account_id,
        local.log_archive_account_id
      ]
    }
    actions   = ["kms:*"]
    resources = ["arn:aws:s3:::${var.org_cloudtrail_s3_bucket.name}"]
  }

  statement {
    sid    = "Allow CloudTrail to encrypt logs"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["kms:GenerateDataKey*"]
    resources = [local.kms_key_resource]
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:aws:cloudtrail:*:${local.root_account_id}:trail/*"]
    }
    condition {
      test     = "StringEquals"
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
    resources = [local.kms_key_resource]
  }

  statement {
    sid    = "Allow principals in the account to decrypt log files"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "kms:Decrypt",
      "kms:ReEncryptFrom"
    ]
    resources = [local.kms_key_resource]
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [local.root_account_id]
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
    resources = [local.kms_key_resource]
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["ec2.${local.aws_region}.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [local.root_account_id]
    }
  }

  statement {
    sid    = "Enable cross account log decryption"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "kms:Decrypt",
      "kms:ReEncryptFrom"
    ]
    resources = [local.kms_key_resource]
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [local.root_account_id, local.log_archive_account_id]
    }
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:aws:cloudtrail:*:${local.root_account_id}:trail/*"]
    }
  }

  # CloudWatch Log Group:
  statement {
    sid    = ""
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
    resources = ["*"] # TODO all resources?
    condition {
      test     = "ArnEquals"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values   = ["arn:aws:logs:${local.aws_region}:${local.root_account_id}:log-group:${local.cw_log_grp.name}"]
    }
  }
}

######################################################################
