output "policy_id" {
  description = "S3 bucket policy ID."
  value       = aws_s3_bucket_policy.frontend_bucket.id
}
