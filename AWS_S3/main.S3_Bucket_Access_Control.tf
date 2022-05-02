######################################################################
### S3 Bucket Access Control
######################################################################
### Object Ownership - Enforce Bucket Owner

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

#---------------------------------------------------------------------
### S3 Bucket Policy

/* TODO merge into bucket policy:

  - If using SSE-KMS, bucket_key will be enabled, so
  - Other SSE conditions?
  - StringNotEqualsIfExists "s3:x-amz-acl": "bucket-owner-full-control"
*/

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id

  policy = jsondecode(var.bucket_policy)
}

#---------------------------------------------------------------------
### S3 Bucket Public Access Blocks

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

######################################################################
