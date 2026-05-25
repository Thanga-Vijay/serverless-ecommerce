variable "name_prefix" {
  description = "Environment-specific resource name prefix."
  type        = string
}

variable "tables" {
  description = "DynamoDB table definitions."
  type = map(object({
    table_name                     = string
    hash_key                       = string
    range_key                      = optional(string)
    ttl_attribute                  = optional(string)
    point_in_time_recovery_enabled = optional(bool, true)
    deletion_protection_enabled    = optional(bool, false)
    stream_enabled                 = optional(bool, false)
    stream_view_type               = optional(string)
    attributes = list(object({
      name = string
      type = string
    }))
    global_secondary_indexes = optional(list(object({
      name            = string
      hash_key        = string
      range_key       = optional(string)
      projection_type = optional(string, "ALL")
    })), [])
  }))
}

variable "tags" {
  description = "Tags applied to resources."
  type        = map(string)
  default     = {}
}
