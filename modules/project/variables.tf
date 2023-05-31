variable "billing_account" {
  description = "The ID of the billing account to associate projects with."
  type        = string
}

variable "folder_name" {
  description = "The Google Cloud folder resource name for this product's resources."
  type        = string
  validation {
    condition     = can(regex("^folders/.*", var.folder_name))
    error_message = "ERROR: folder_name must be in the format folder/*"
  }
}

variable "project_id" {
  description = "The ID for this project."
  type        = string
}

variable "project_services" {
  description = "The Google Cloud services to enable on this project."
  type        = list(string)
  default     = []
}

variable "enable_suffix" {
  description = "Append a random 6 character suffix to the project ID (default: true)."
  type        = bool
  default     = true
}

variable "enable_project_lien" {
  description = "Enable a project lien to prevent deletion via the Google Cloud UI (default: true)."
  type        = bool
  default     = true
}
