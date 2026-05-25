locals {
  buckets = {
    frontend        = "${var.name_prefix}-${var.frontend_bucket}"
    product_images  = "${var.name_prefix}-${var.product_bucket}"
    logs            = "${var.name_prefix}-access-logs"
    terraform_state = var.terraform_bucket
  }
}

resource "aws_s3_bucket" "this" {
  for_each = local.buckets

  bucket        = each.value
  force_destroy = each.key == "terraform_state" ? false : var.force_destroy

  tags = merge(var.tags, {
    Name = each.value
  })
}

resource "aws_s3_bucket_public_access_block" "this" {
  for_each = {
    for k, v in aws_s3_bucket.this : k => v if k != "logs"
  }

  bucket                  = each.value.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.this["logs"].id

  block_public_acls       = false
  block_public_policy     = true
  ignore_public_acls      = false
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "this" {
  for_each = aws_s3_bucket.this

  bucket = each.value.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  for_each = aws_s3_bucket.this

  bucket = each.value.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "this" {
  for_each = aws_s3_bucket.this

  bucket = each.value.id

  rule {
    object_ownership = each.key == "logs" ? "BucketOwnerPreferred" : "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_acl" "logs" {
  bucket = aws_s3_bucket.this["logs"].id
  acl    = "log-delivery-write"

  depends_on = [
    aws_s3_bucket_ownership_controls.this
  ]
}

resource "aws_s3_bucket_lifecycle_configuration" "product_images" {
  bucket = aws_s3_bucket.this["product_images"].id

  rule {
    id     = "expire-incomplete-uploads"
    status = "Enabled"

    filter {
      prefix = ""
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}

resource "aws_s3_bucket_cors_configuration" "product_images" {
  bucket = aws_s3_bucket.this["product_images"].id

  cors_rule {
    allowed_headers = ["content-type", "x-amz-acl", "x-amz-meta-*"]
    allowed_methods = ["PUT", "POST"]
    allowed_origins = var.allowed_origins
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}
