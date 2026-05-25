variable "name_prefix" {
  description = "Environment-specific resource name prefix."
  type        = string
}

variable "lambda_services" {
  description = "Least-privilege access model for each Lambda service."
  type = map(object({
    dynamodb_tables = list(string)
    sqs_queues      = list(string)
    sns_topics      = list(string)
    s3_buckets      = list(string)
  }))
}

variable "dynamodb_table_arns" {
  description = "DynamoDB table ARNs keyed by logical table."
  type        = map(string)
}

variable "sqs_queue_arns" {
  description = "SQS queue ARNs keyed by logical queue."
  type        = map(string)
}

variable "sns_topic_arns" {
  description = "SNS topic ARNs keyed by logical topic."
  type        = map(string)
}

variable "s3_bucket_arns" {
  description = "S3 bucket ARNs keyed by purpose."
  type        = map(string)
}

variable "tags" {
  description = "Tags applied to resources."
  type        = map(string)
  default     = {}
}
