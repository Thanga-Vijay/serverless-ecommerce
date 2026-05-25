output "bucket_names" {
  description = "Bucket names keyed by purpose."
  value       = { for key, bucket in aws_s3_bucket.this : key => bucket.bucket }
}

output "bucket_arns" {
  description = "Bucket ARNs keyed by purpose."
  value       = { for key, bucket in aws_s3_bucket.this : key => bucket.arn }
}

output "frontend_bucket_id" {
  description = "Frontend S3 bucket ID."
  value       = aws_s3_bucket.this["frontend"].id
}

output "frontend_bucket_arn" {
  description = "Frontend S3 bucket ARN."
  value       = aws_s3_bucket.this["frontend"].arn
}

output "frontend_bucket_regional_domain_name" {
  description = "Frontend S3 regional domain name."
  value       = aws_s3_bucket.this["frontend"].bucket_regional_domain_name
}

output "logs_bucket_domain_name" {
  description = "CloudFront logs bucket domain name."
  value       = aws_s3_bucket.this["logs"].bucket_domain_name
}
