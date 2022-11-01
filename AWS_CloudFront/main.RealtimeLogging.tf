######################################################################
### AWS CloudFront - Realtime Logging Config

resource "aws_cloudfront_realtime_log_config" "map" {
  for_each = var.realtime_log_configs != null ? var.realtime_log_configs : {}

  name          = each.value.name
  sampling_rate = each.value.sampling_rate
  fields        = each.value.fields

  endpoint {
    stream_type = "Kinesis"

    kinesis_stream_config {
      stream_arn = each.value.kinesis_stream_arn
      role_arn   = each.value.kinesis_stream_role_arn
    }
  }
}

######################################################################
