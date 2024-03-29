######################################################################
### AWS Lambda

locals {
  # deployment_package_src: provide default object if s3_bucket is null
  # This prevents us from having to handle the null-lookup case 3 separate times.
  s3_bucket_src = (
    var.deployment_package_src.s3_bucket != null
    ? var.deployment_package_src.s3_bucket
    : { bucket_name = null, object_key = null, object_version = null }
  )
}

resource "aws_lambda_function" "this" {
  function_name = var.name
  description   = var.description
  role          = aws_iam_role.Lambda_ExecRole.arn
  publish       = var.should_publish_new_version

  # These two must not be provided when using an ECR image package type
  handler = var.deployment_package_src.image_uri != null ? null : var.handler
  runtime = var.deployment_package_src.image_uri != null ? null : var.runtime

  # Deployment Package Source
  filename          = var.deployment_package_src.local_file_abs_path
  source_code_hash  = var.deployment_package_src.local_file_abs_path != null ? filebase64sha256(var.deployment_package_src.local_file_abs_path) : null
  image_uri         = var.deployment_package_src.image_uri
  package_type      = var.deployment_package_src.image_uri != null ? "Image" : "Zip"
  s3_bucket         = local.s3_bucket_src.bucket_name
  s3_key            = local.s3_bucket_src.object_key
  s3_object_version = local.s3_bucket_src.object_version

  dynamic "vpc_config" {
    for_each = var.vpc_config != null ? [var.vpc_config] : []

    content {
      security_group_ids = var.vpc_config.security_group_ids
      subnet_ids         = var.vpc_config.subnet_ids
    }
  }

  dynamic "dead_letter_config" {
    for_each = var.dead_letter_target_arn != null ? [var.dead_letter_target_arn] : []

    content {
      target_arn = var.dead_letter_target_arn
    }
  }

  dynamic "environment" {
    for_each = var.environment_variables != null ? [var.environment_variables] : []

    content {
      variables = var.environment_variables
    }
  }

  tracing_config {
    mode = "Active" # "PassThrough" is also valid here, but see link below.
    # https://aquasecurity.github.io/tfsec/v1.26.3/checks/aws/lambda/enable-tracing/
  }

  tags = var.tags
}

#---------------------------------------------------------------------

resource "aws_lambda_provisioned_concurrency_config" "this" {
  function_name                     = aws_lambda_function.this.function_name
  qualifier                         = aws_lambda_function.this.version
  provisioned_concurrent_executions = var.provisioned_concurrent_executions # Default: 1
}

######################################################################
