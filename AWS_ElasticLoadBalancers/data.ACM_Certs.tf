######################################################################
### ACM Certificates

data "aws_acm_certificate" "map" {
  for_each = {
    for listener_name, listener_config in var.listeners : listener_name => listener_config
    if listener_config.certificate != null
  }

  domain      = each.value.certificate.domain
  types       = [each.value.certificate.type]
  statuses    = [each.value.certificate.status]
  most_recent = each.value.certificate.most_recent
}

######################################################################
