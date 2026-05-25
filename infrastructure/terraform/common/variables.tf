variable "project_name" {
  description = "Project name used in resource names and tags."
  type        = string
  default     = "serverless-ecommerce"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,40}$", var.project_name))
    error_message = "project_name must be lowercase kebab-case and 3-41 characters long."
  }
}

variable "environment" {
  description = "Deployment environment name."
  type        = string

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be dev or prod."
  }
}

variable "aws_region" {
  description = "AWS region for regional resources."
  type        = string
  default     = "us-east-1"
}

variable "owner" {
  description = "Team or person responsible for the stack."
  type        = string
  default     = "platform"
}

variable "allowed_cors_origins" {
  description = "Origins allowed to call the API."
  type        = list(string)
  default     = ["*"]
}

variable "cognito_mfa_configuration" {
  description = "Cognito MFA configuration. Valid values are OFF, OPTIONAL, or ON."
  type        = string
  default     = "OPTIONAL"

  validation {
    condition     = contains(["OFF", "OPTIONAL", "ON"], var.cognito_mfa_configuration)
    error_message = "cognito_mfa_configuration must be OFF, OPTIONAL, or ON."
  }
}

variable "cognito_callback_urls" {
  description = "OAuth callback URLs for the frontend."
  type        = list(string)
  default     = []
}

variable "cognito_logout_urls" {
  description = "OAuth logout URLs for the frontend."
  type        = list(string)
  default     = []
}

variable "notification_email_subscriptions" {
  description = "Email addresses subscribed to order notification SNS topic."
  type        = list(string)
  default     = []
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days."
  type        = number
  default     = 30
}

variable "alarm_email_topic_arn" {
  description = "Optional SNS topic ARN notified by CloudWatch alarms."
  type        = string
  default     = null
}

variable "extra_tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
