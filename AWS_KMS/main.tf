######################################################################
### AWS KMS

resource "aws_kms_key" "this" {
  description         = var.key_description
  policy              = var.key_policy
  multi_region        = var.is_multi_region_key
  enable_key_rotation = var.should_enable_key_rotation
  tags                = var.key_tags
}

#---------------------------------------------------------------------
### KMS Key Alias

resource "aws_kms_alias" "list" {
  count = var.key_alias != null ? 1 : 0

  name          = var.key_alias
  target_key_id = aws_kms_key.this.key_id
}

######################################################################
