variable "name_prefix" {
  description = "Environment-specific resource name prefix."
  type        = string
}

variable "stage_name" {
  description = "API Gateway stage name."
  type        = string
}

variable "routes" {
  description = "HTTP API route definitions keyed by logical route name."
  type = map(object({
    route_key          = string
    authorization_type = string
    service            = string
  }))
}

variable "lambda_integrations" {
  description = "Lambda invoke ARNs keyed by service name. Empty until backend Lambdas exist."
  type        = map(string)
  default     = {}
}

variable "cognito_user_pool_endpoint" {
  description = "Cognito user pool endpoint used as JWT issuer."
  type        = string
}

variable "cognito_app_client_id" {
  description = "Cognito app client ID used as JWT audience."
  type        = string
}

variable "allowed_cors_origins" {
  description = "Allowed CORS origins."
  type        = list(string)
}

variable "log_retention_days" {
  description = "API Gateway access log retention in days."
  type        = number
}

variable "throttling_burst_limit" {
  description = "Stage-level throttling burst limit."
  type        = number
}

variable "throttling_rate_limit" {
  description = "Stage-level throttling rate limit."
  type        = number
}

variable "tags" {
  description = "Tags applied to resources."
  type        = map(string)
  default     = {}
}
