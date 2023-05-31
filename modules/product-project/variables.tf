variable "billing_account" {
  description = "The ID of the billing account to associate projects with."
  type        = string
}

variable "project_id" {
  description = "The ID for this set of projects."
  type        = string
  validation {
    condition     = length(var.project_id) <= 21
    error_message = "ERROR: project_id must be <= 21 characters."
  }
}

variable "project_services" {
  description = "The Google Cloud services to enable on this project."
  type        = list(string)
  default     = []
}

variable "project_iam" {
  description = "Member identities for project IAM, in {MEMBER => [ROLES]} format."
  type        = map(list(string))
  default     = {}
  nullable    = false
}

variable "environments" {
  description = "The product environments to create this project in."
  type        = map(string)
}

variable "iac_service_account_email" {
  description = "The IaC service account email address for this project. Given editor permissions by default."
  type        = string
  default     = null
}

variable "guardian_service_account_email" {
  description = "The Guardian service account email address for this project. Given editor permissions by default."
  type        = string
  default     = null
}

variable "bucket_name" {
  description = "The name of the bucket containing the organization's terraform state."
  type        = string
}

variable "bucket_root_prefix" {
  description = "The root prefix shared across all bucket prefixes."
  type        = string
  default     = "gcp-org"
}
