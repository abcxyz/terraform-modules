variable "product_folder_name" {
  description = "The product folder resource name for this environment's resources."
  type        = string
  validation {
    condition     = can(regex("^folders/.*", var.product_folder_name))
    error_message = "ERROR: product_folder_name must be in the format folder/*"
  }
}

variable "environment_id" {
  description = "An ID for this environment."
  type        = string
}

variable "team_group_email" {
  description = "The team group email address for this product."
  type        = string
}

variable "breakglass_group_email" {
  description = "The breakglass group email address for this product."
  type        = string
}

variable "org_product_environments" {
  description = "The list of organization product environments."
  type = map(object({
    privileged = optional(bool, false)
  }))
}

variable "org_tag_keys" {
  description = "The list of organization tag keys."
  type        = map(any)
}

variable "org_tag_values" {
  description = "The list of organization tag key values."
  type        = map(any)
}
