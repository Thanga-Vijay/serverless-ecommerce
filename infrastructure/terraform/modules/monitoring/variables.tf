variable "name_prefix" {
  description = "Environment-specific resource name prefix."
  type        = string
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days."
  type        = number
}

variable "lambda_function_names" {
  description = "Expected Lambda function names for pre-created log groups and alarms."
  type        = list(string)
}

variable "api_id" {
  description = "API Gateway ID for CloudWatch metrics."
  type        = string
}

variable "sqs_dlq_names" {
  description = "SQS DLQ names keyed by logical queue."
  type        = map(string)
}

variable "dynamodb_table_names" {
  description = "DynamoDB table names keyed by logical table."
  type        = map(string)
}

variable "alarm_actions" {
  description = "Alarm action ARNs."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to resources."
  type        = map(string)
  default     = {}
}
