variable "frontend_bucket_id" {
  description = "Frontend S3 bucket ID."
  type        = string
}

variable "frontend_bucket_arn" {
  description = "Frontend S3 bucket ARN."
  type        = string
}

variable "cloudfront_distribution_arn" {
  description = "CloudFront distribution ARN allowed to read frontend objects."
  type        = string
}
