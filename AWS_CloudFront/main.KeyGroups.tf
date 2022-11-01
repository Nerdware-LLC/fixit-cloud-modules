######################################################################
### AWS CloudFront - Key Groups

resource "aws_cloudfront_key_group" "map" {
  for_each = var.trusted_key_groups != null ? var.trusted_key_groups : {}

  name    = each.key
  items   = [for key in each.value.key_names : aws_cloudfront_public_key.map[key].id]
  comment = each.value.comment
}

resource "aws_cloudfront_public_key" "map" {
  for_each = var.public_keys != null ? var.public_keys : {}

  name        = each.key
  encoded_key = each.value.encoded_key
  comment     = each.value.comment
}

######################################################################
