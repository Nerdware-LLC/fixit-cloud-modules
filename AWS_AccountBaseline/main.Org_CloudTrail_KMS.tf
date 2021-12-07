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
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.account_params.id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"] # TODO all resources?
  }

  statement {
    sid    = "Allow CloudTrail to encrypt logs"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions = ["kms:GenerateDataKey*"]

    # TODO Below change was made to fix circular dep issue; update key policy later.
    # resources = ["arn:aws:kms:${local.aws_region}:${var.account_params.id}:key/${aws_kms_key.Org_CloudTrail_KMS_Key.id}"]
    resources = ["arn:aws:kms:${local.aws_region}:${var.account_params.id}:key/*"]

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:aws:cloudtrail:*:${var.account_params.id}:trail/*"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:aws:cloudtrail:${local.aws_region}:${var.account_params.id}:trail/${var.org_cloudtrail.name}"]
    }
  }

  # TODO review this statement; not sure if this is what we want.
  statement {
    sid    = "Allow CloudTrail to describe key"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["kms:DescribeKey"]
    resources = ["*"] # TODO all resources?
  }

  # TODO review this statement; not sure if this is what we want.
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
    resources = ["*"] # TODO all resources?
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

  # TODO review this statement; not sure if this is what we want.
  statement {
    sid    = "Allow alias creation during setup"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"] # TODO all principals?
    }
    actions   = ["kms:CreateAlias"]
    resources = ["*"] # TODO all resources?
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

  # TODO review this statement; not sure if this is what we want.
  statement {
    sid    = "Enable cross account log decryption"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"] # TODO all principals?
    }
    actions = [
      "kms:Decrypt",
      "kms:ReEncryptFrom"
    ]
    resources = ["*"] # TODO all resources?
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
      values   = ["arn:aws:logs:${local.aws_region}:${var.account_params.id}:log-group:${local.cw_log_grp.name}"]
    }
  }
}

######################################################################
