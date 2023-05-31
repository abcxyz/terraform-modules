variable "parent" {
  description = "The Google Cloud parent resource for the associated resources."
  type        = string
}

variable "billing_account" {
  description = "The ID of the billing account to associate projects with."
  type        = string
}

variable "owner" {
  description = "The owner of this project in member resource format (e.g. user:ldap@domain.com, group:name@domain.com)"
  type        = string
}

variable "short_name" {
  description = "A short descriptive name for this project to be used for resource naming. The length of this string is limited to 23 characters. This variable is unused when `project_id` is provided."
  type        = string
  validation {
    condition     = length(var.short_name) <= 23
    error_message = "ERROR: short_name must be 23 characters or less."
  }
}

variable "project_id" {
  description = "Use a specific project id instead of the generated one. This is useful when migrating existing projects."
  type        = string
  default     = null
}
