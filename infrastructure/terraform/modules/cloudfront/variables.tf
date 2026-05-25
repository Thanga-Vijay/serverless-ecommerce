variable "name_prefix" {
  description = "Environment-specific resource name prefix."
  type        = string
}

variable "origin_bucket_domain_name" {
  description = "Frontend S3 bucket regional domain name."
  type        = string
}

variable "origin_bucket_id" {
  description = "Frontend S3 bucket ID used as CloudFront origin ID."
  type        = string
}

variable "log_bucket_domain_name" {
  description = "S3 bucket domain name for CloudFront access logs."
  type        = string
}

variable "response_headers_policy_id" {
  description = "CloudFront security response headers policy ID."
  type        = string
}

variable "price_class" {
  description = "CloudFront price class."
  type        = string
  default     = "PriceClass_100"
}

variable "tags" {
  description = "Tags applied to resources."
  type        = map(string)
  default     = {}
}
