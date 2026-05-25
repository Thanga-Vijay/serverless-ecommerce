variable "project_name" {
  description = "Project name used in resource names and tags."
  type        = string
  default     = "serverless-ecommerce"
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "prod"
}

variable "owner" {
  description = "Team or person responsible for the stack."
  type        = string
  default     = "platform"
}

variable "allowed_cors_origins" {
  description = "Origins allowed to call the API."
  type        = list(string)
  default     = ["https://example.com"]
}

variable "cognito_callback_urls" {
  description = "OAuth callback URLs for prod."
  type        = list(string)
  default     = []
}

variable "cognito_logout_urls" {
  description = "OAuth logout URLs for prod."
  type        = list(string)
  default     = []
}

variable "notification_email_subscriptions" {
  description = "Email addresses subscribed to order notification topic."
  type        = list(string)
  default     = []
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days."
  type        = number
  default     = 90
}

variable "alarm_email_topic_arn" {
  description = "Optional SNS topic ARN notified by CloudWatch alarms."
  type        = string
  default     = null
}

variable "extra_tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default = {
    CostCenter = "serverless-ecommerce-prod"
  }
}
