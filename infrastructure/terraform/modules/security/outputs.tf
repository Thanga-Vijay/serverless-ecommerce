output "response_headers_policy_id" {
  description = "CloudFront response headers policy ID."
  value       = aws_cloudfront_response_headers_policy.security.id
}
