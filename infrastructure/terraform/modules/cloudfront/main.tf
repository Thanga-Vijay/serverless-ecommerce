resource "aws_cloudfront_origin_access_control" "this" {
  name                              = "${var.name_prefix}-frontend-oac"
  description                       = "Origin access control for ${var.name_prefix} frontend bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_cache_policy" "static_assets" {
  name        = "${var.name_prefix}-static-assets"
  comment     = "Optimized cache policy for static frontend assets"
  default_ttl = 86400
  max_ttl     = 31536000
  min_ttl     = 0

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true

    cookies_config {
      cookie_behavior = "none"
    }

    headers_config {
      header_behavior = "none"
    }

    query_strings_config {
      query_string_behavior = "none"
    }
  }
}

resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  comment             = "${var.name_prefix} frontend distribution"
  default_root_object = "index.html"
  price_class         = var.price_class
  http_version        = "http2and3"

  origin {
    domain_name              = var.origin_bucket_domain_name
    origin_id                = var.origin_bucket_id
    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
  }

  default_cache_behavior {
    allowed_methods            = ["GET", "HEAD", "OPTIONS"]
    cached_methods             = ["GET", "HEAD"]
    cache_policy_id            = aws_cloudfront_cache_policy.static_assets.id
    compress                   = true
    response_headers_policy_id = var.response_headers_policy_id
    target_origin_id           = var.origin_bucket_id
    viewer_protocol_policy     = "redirect-to-https"
  }

  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  logging_config {
    bucket          = var.log_bucket_domain_name
    include_cookies = false
    prefix          = "cloudfront/"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  tags = var.tags
}
