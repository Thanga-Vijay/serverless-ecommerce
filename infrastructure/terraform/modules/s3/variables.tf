variable "name_prefix" {
  description = "Globally unique prefix for bucket names."
  type        = string
}

variable "terraform_bucket" {
  description = "Existing or managed S3 bucket name for Terraform state."
  type        = string
}

variable "frontend_bucket" {
  description = "Frontend bucket name suffix."
  type        = string
}

variable "product_bucket" {
  description = "Product image bucket name suffix."
  type        = string
}

variable "force_destroy" {
  description = "Whether non-state buckets can be force destroyed."
  type        = bool
  default     = false
}

variable "allowed_origins" {
  description = "CORS origins allowed for product image uploads."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to resources."
  type        = map(string)
  default     = {}
}
