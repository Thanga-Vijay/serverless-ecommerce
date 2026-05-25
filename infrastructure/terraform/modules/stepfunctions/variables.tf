variable "name_prefix" {
  description = "Environment-specific resource name prefix."
  type        = string
}

variable "execution_role_arn" {
  description = "Step Functions execution role ARN."
  type        = string
}

variable "log_group_arn" {
  description = "CloudWatch log group ARN for Step Functions execution logs."
  type        = string
}

variable "state_machines" {
  description = "State machine definitions."
  type = map(object({
    definition = string
    type       = optional(string, "STANDARD")
  }))
}

variable "tags" {
  description = "Tags applied to resources."
  type        = map(string)
  default     = {}
}
