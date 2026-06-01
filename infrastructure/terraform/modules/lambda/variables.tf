variable "name_prefix" {
  description = "Environment-specific resource prefix, for example serverless-ecommerce-dev."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "aws_region" {
  description = "AWS region for Lambda runtime configuration."
  type        = string
}

variable "lambda_role_arns" {
  description = "IAM execution role ARNs keyed by Lambda service name."
  type        = map(string)
}

variable "lambda_services" {
  description = "Lambda infrastructure configuration keyed by service name."
  type = map(object({
    runtime               = string
    handler               = string
    timeout               = number
    memory_size           = number
    environment_variables = map(string)
    sqs_queue_arns        = optional(list(string), [])
    architectures         = optional(list(string), ["arm64"])
  }))

  validation {
    condition = alltrue([
      for service in values(var.lambda_services) :
      contains(["nodejs20.x", "nodejs22.x", "python3.12", "python3.13", "java21"], service.runtime)
    ])
    error_message = "Use a supported Lambda runtime."
  }

  validation {
    condition = alltrue([
      for service in values(var.lambda_services) :
      service.timeout >= 1 && service.timeout <= 900
    ])
    error_message = "Lambda timeout must be between 1 and 900 seconds."
  }

  validation {
    condition = alltrue([
      for service in values(var.lambda_services) :
      service.memory_size >= 128 && service.memory_size <= 10240
    ])
    error_message = "Lambda memory_size must be between 128 and 10240 MB."
  }
}

variable "api_source_account" {
  description = "AWS account ID allowed to invoke Lambda through API Gateway."
  type        = string
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days."
  type        = number
  default     = 30
}

variable "log_level" {
  description = "Default application log level."
  type        = string
  default     = "INFO"

  validation {
    condition     = contains(["DEBUG", "INFO", "WARN", "ERROR"], var.log_level)
    error_message = "log_level must be DEBUG, INFO, WARN, or ERROR."
  }
}

variable "sqs_batch_size" {
  description = "Default SQS event source batch size."
  type        = number
  default     = 10
}

variable "sqs_batch_window_seconds" {
  description = "Default SQS event source maximum batching window."
  type        = number
  default     = 5
}

variable "tags" {
  description = "Tags applied to Lambda resources."
  type        = map(string)
  default     = {}
}
