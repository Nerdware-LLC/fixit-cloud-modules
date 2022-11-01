######################################################################
### AWS CloudFront - Realtime Logging Config

resource "aws_cloudfront_function" "map" {
  for_each = var.cloudfront_functions != null ? var.cloudfront_functions : {}

  name    = each.key
  runtime = each.value.runtime
  code    = each.value.code
  comment = each.value.comment
  publish = each.value.publish
}

######################################################################
