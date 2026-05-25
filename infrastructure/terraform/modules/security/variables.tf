variable "name_prefix" {
  description = "Environment-specific resource name prefix."
  type        = string
}

variable "tags" {
  description = "Reserved for future security resources such as WAF."
  type        = map(string)
  default     = {}
}
