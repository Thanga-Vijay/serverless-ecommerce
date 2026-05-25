variable "name_prefix" {
  description = "Environment-specific resource name prefix."
  type        = string
}

variable "mfa_configuration" {
  description = "Cognito MFA configuration."
  type        = string
  default     = "OPTIONAL"
}

variable "callback_urls" {
  description = "OAuth callback URLs."
  type        = list(string)
}

variable "logout_urls" {
  description = "OAuth logout URLs."
  type        = list(string)
}

variable "access_token_minutes" {
  description = "Access token expiration in minutes."
  type        = number
  default     = 60
}

variable "id_token_minutes" {
  description = "ID token expiration in minutes."
  type        = number
  default     = 60
}

variable "refresh_token_days" {
  description = "Refresh token expiration in days."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags applied to resources."
  type        = map(string)
  default     = {}
}
