variable "name_prefix" {
  description = "Environment-specific resource name prefix."
  type        = string
}

variable "queues" {
  description = "SQS queue definitions."
  type = map(object({
    visibility_timeout_seconds = number
    message_retention_seconds  = number
    max_receive_count          = number
  }))
}

variable "tags" {
  description = "Tags applied to resources."
  type        = map(string)
  default     = {}
}
