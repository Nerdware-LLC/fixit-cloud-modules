######################################################################
### AWS CloudFront - S3 Origin Access Controls

resource "aws_cloudfront_origin_access_control" "map" {
  for_each = {
    for origin_domain, origin_config in var.origins : origin_domain => origin_config
    if origin_config.s3_origin_oac_config != null
  }

  name                              = each.value.s3_origin_access_control_config.name
  description                       = each.value.s3_origin_access_control_config.description
  origin_access_control_origin_type = "s3" # <-- only valid value
  signing_behavior                  = each.value.s3_origin_access_control_config.signing_behavior
  signing_protocol                  = "sigv4" # <-- only valid value
}

######################################################################
