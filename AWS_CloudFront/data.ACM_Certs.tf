######################################################################
### ACM Certificate

data "aws_acm_certificate" "map" {
  for_each = (
    var.viewer_certificate.acm_certificate_domain != null
    ? { (var.viewer_certificate.acm_certificate_domain) = var.viewer_certificate.acm_certificate_domain }
    : {}
  )

  domain      = var.viewer_certificate.acm_certificate_domain
  most_recent = true
}

######################################################################
