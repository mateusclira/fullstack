resource "aws_s3_bucket" "buckets" {
  count  = length(var.environments)
  bucket = "${var.environments[count.index]}-${var.bucket_suffix}"
}

resource "aws_s3_bucket_ownership_controls" "bucket_control" {
  count  = length(var.environments)
  bucket = aws_s3_bucket.buckets[count.index].id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "bucket_public_access" {
  count  = length(var.environments)
  bucket = aws_s3_bucket.buckets[count.index].id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.bucket_control,
    aws_s3_bucket_public_access_block.bucket_public_access,
  ]
  count  = length(var.environments)
  bucket = aws_s3_bucket.buckets[count.index].id
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "buckets_policy" {
  count  = length(var.environments)
  bucket = aws_s3_bucket.buckets[count.index].id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${var.environments[count.index]}-${var.bucket_suffix}/*"
    }
  ]
}
POLICY
}

resource "aws_s3_bucket_website_configuration" "website_config" {
  count  = length(var.environments)
  bucket = aws_s3_bucket.buckets[count.index].id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}
