######################################################################
### S3 Web Host

resource "aws_s3_bucket_website_configuration" "list" {
  count = var.web_host_config != null ? 1 : 0

  bucket = aws_s3_bucket.this.bucket

  # routing.index_document
  dynamic "index_document" {
    for_each = (
      var.web_host_config.routing != null
      ? [var.web_host_config.routing.index_document]
      : []
    )
    content {
      suffix = index_document.value
    }
  }

  # routing.error_document
  dynamic "error_document" {
    for_each = (
      can(lookup(var.web_host_config.routing, "error_document"))
      ? [var.web_host_config.routing.error_document]
      : []
    )
    content {
      key = error_document.value
    }
  }

  # routing.redirect_rules
  dynamic "routing_rule" {
    for_each = var.web_host_config.routing.redirect_rules
    content {

      # routing.redirect_rules => .condition
      dynamic "condition" {
        for_each = (
          routing_rule.value.condition != null
          ? [routing_rule.value.condition]
          : []
        )
        content {
          http_error_code_returned_equals = condition.value.http_error_code_returned_equals
          key_prefix_equals               = condition.value.key_prefix_equals
        }
      }

      # routing.redirect_rules => .redirect
      redirect {
        host_name               = routing_rule.value.host_name
        http_redirect_code      = routing_rule.value.http_redirect_code
        protocol                = routing_rule.value.protocol
        replace_key_with        = try(routing_rule.value.replace.key_with, null)
        replace_key_prefix_with = try(routing_rule.value.replace.key_prefix_with, null)
      }
    }
  }

  # This is the alternative to detailed "routing" properties
  dynamic "redirect_all_requests_to" {
    for_each = (
      var.web_host_config.redirect_all_requests_to != null
      ? [var.web_host_config.redirect_all_requests_to]
      : []
    )
    content {
      host_name = redirect_all_requests_to.value.host_name
      protocol  = redirect_all_requests_to.value.protocol
    }
  }
}

#---------------------------------------------------------------------
### S3 CORS Config

resource "aws_s3_bucket_cors_configuration" "list" {
  count = var.cors_rules != null ? 1 : 0

  bucket = aws_s3_bucket.this.bucket

  dynamic "cors_rule" {
    for_each = var.cors_rules

    content {
      id              = cors_rule.key
      allowed_methods = cors_rule.value.allowed_methods # required                        # required
      allowed_origins = cors_rule.value.allowed_origins # required
      allowed_headers = cors_rule.value.allowed_headers
      expose_headers  = cors_rule.value.expose_headers
      max_age_seconds = cors_rule.value.max_age_seconds
    }
  }
}

######################################################################
