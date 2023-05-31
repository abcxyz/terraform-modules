variable "project_id" {
  description = "The Google Cloud project ID for these resources."
  type        = string
  validation {
    condition     = length(var.project_id) <= 30
    error_message = "ERROR: project_id must be <= 30 characters."
  }
}

variable "id" {
  description = "An ID for these resources."
  type        = string
  validation {
    condition     = length(var.id) <= 22
    error_message = "ERROR: id must be 22 characters or less."
  }
}

variable "bucket_admin_email" {
  description = "The service account email address for the storage bucket admin role."
  type        = string
}
