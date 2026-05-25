variable "create_functions" {
  description = "Whether to create Lambda functions."
  type        = bool
  default     = false
}

variable "name_prefix" {
  description = "Prefix for Lambda function names."
  type        = string
}

variable "execution_role_arn" {
  description = "Lambda execution role ARN."
  type        = string
}

variable "api_execution_arn" {
  description = "API Gateway execution ARN allowed to invoke Lambda."
  type        = string
  default     = "*"
}

variable "functions" {
  description = "Lambda functions keyed by logical name."
  type = map(object({
    handler        = string
    runtime        = string
    timeout        = optional(number, 30)
    memory_size    = optional(number, 256)
    s3_bucket      = optional(string)
    s3_key         = optional(string)
    architectures  = optional(list(string), ["arm64"])
    environment    = optional(map(string), {})
    policy_actions = optional(list(string), [])
  }))
  default = {}
}

variable "tags" {
  description = "Tags applied to resources."
  type        = map(string)
  default     = {}
}
