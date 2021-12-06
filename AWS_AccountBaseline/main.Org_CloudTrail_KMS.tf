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

data "aws_iam_policy_document" "Org_CloudTrail_KMS_Key" {
  policy_id = "Key policy created for Org_CloudTrail_KMS_Key"

  statement {
    sid = "Enable IAM User Permissions"

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${var.account_params.id}:root"
      ]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid = "Allow CloudTrail to encrypt logs"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["kms:GenerateDataKey*"]
    resources = ["*"]
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:aws:cloudtrail:*:${var.account_params.id}:trail/*"]
    }
  }

  statement {
    sid = "Allow CloudTrail to describe key"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["kms:DescribeKey"]
    resources = ["*"]
  }

  statement {
    sid = "Allow principals in the account to decrypt log files"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "kms:Decrypt",
      "kms:ReEncryptFrom"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [var.account_params.id]
    }
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:aws:cloudtrail:*:${var.account_params.id}:trail/*"]
    }
  }

  statement {
    sid = "Allow alias creation during setup"
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
      values   = [var.account_params.id]
    }
  }

  statement {
    sid = "Enable cross account log decryption"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "kms:Decrypt",
      "kms:ReEncryptFrom"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [var.account_params.id]
    }
    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:aws:cloudtrail:*:${var.account_params.id}:trail/*"]
    }
  }

  # https://docs.aws.amazon.com/awscloudtrail/latest/userguide/cloudtrail-permissions-for-sns-notifications.html
  statement {
    sid = "Allow CloudTrail to send notifications to the encrypted SNS topic"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions = [
      "kms:GenerateDataKey*",
      "kms:Decrypt"
    ]
    resources = ["*"]
  }
}

######################################################################
