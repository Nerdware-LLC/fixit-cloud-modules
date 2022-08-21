######################################################################
### AWS Lambda

resource "aws_lambda_function" "this" {
  function_name = var.name
  description   = var.description
  role          = aws_iam_role.Lambda_ExecRole.arn
  handler       = var.handler
  runtime       = var.runtime

  # Deployment Package Source
  filename          = var.deployment_package_src.local_file_abs_path
  source_code_hash  = filebase64sha256(var.deployment_package_src.local_file_abs_path)
  image_uri         = var.deployment_package_src.image_uri
  s3_bucket         = local.s3_bucket_src.bucket_name
  s3_key            = local.s3_bucket_src.object_key
  s3_object_version = local.s3_bucket_src.object_version

  dynamic "vpc_config" {
    for_each = var.vpc_config != null ? [var.vpc_config] : []

    content {
      security_group_ids = each.value.security_group_ids
      subnet_ids         = each.value.subnet_ids
    }
  }

  dynamic "dead_letter_config" {
    for_each = var.dead_letter_target_arn != null ? [var.dead_letter_target_arn] : []

    content {
      target_arn = each.value
    }
  }

  dynamic "environment" {
    for_each = var.environment_variables != null ? [var.environment_variables] : []

    content {
      variables = each.value
    }
  }

  tracing_config {
    mode = "Active" # "PassThrough" is also valid here, but see link below.
    # https://aquasecurity.github.io/tfsec/v1.26.3/checks/aws/lambda/enable-tracing/
  }

  tags = var.tags
}

locals {
  # deployment_package_src: provide default object if s3_bucket is null
  # This prevents us from having to handle the null-lookup case 3 separate times.
  s3_bucket_src = (
    var.deployment_package_src.s3_bucket != null
    ? var.deployment_package_src.s3_bucket
    : { bucket_name = null, object_key = null, object_version = null }
  )
}

#---------------------------------------------------------------------

resource "aws_lambda_provisioned_concurrency_config" "this" {
  function_name                     = aws_lambda_function.this.function_name
  qualifier                         = aws_lambda_function.this.version
  provisioned_concurrent_executions = var.provisioned_concurrent_executions # Default: 1
}

######################################################################
