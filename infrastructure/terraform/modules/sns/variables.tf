variable "name_prefix" {
  description = "Environment-specific resource name prefix."
  type        = string
}

variable "order_topic_name" {
  description = "Order notification topic suffix."
  type        = string
}

variable "email_subscriptions" {
  description = "Email endpoints subscribed to the order notification topic."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to resources."
  type        = map(string)
  default     = {}
}
