variable "parent_name" {
  description = "The Google Cloud parent resource for this product's resources."
  type        = string
  validation {
    condition     = can(regex("^(folders|organization)/.*", var.parent_name))
    error_message = "ERROR: parent_name must be in the format folders|organization/*"
  }
}

variable "product_id" {
  description = "An ID for this product."
  type        = string
}

variable "environments" {
  description = "A list of environments this product will have."
  type        = list(string)
}

variable "team_group_email" {
  description = "The team group email address for this project."
  type        = string
}

variable "breakglass_group_email" {
  description = "The breakglass group email address for this project."
  type        = string
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
