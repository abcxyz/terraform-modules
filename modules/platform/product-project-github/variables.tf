variable "billing_account" {
  description = "The ID of the billing account to associate projects with."
  type        = string
}

variable "project_id" {
  description = "The ID for this set of projects."
  type        = string
  validation {
    condition     = length(var.project_id) <= 20
    error_message = "ERROR: project_id must be <= 20 characters."
  }
}

variable "project_services" {
  description = "The Google Cloud services to enable on this project."
  type        = list(string)
  default     = []
}

variable "environments" {
  description = "The product environments to create this project in."
  type        = map(string)
}

variable "guardian" {
  description = "Enable the use of Guardian, this will create storage buckets for Terraform and Guardian and use a restricted Workload Identity Federation attribute condition for using Guardian securely."
  type = object({
    enabled                        = bool
    enable_wif_attribute_condition = optional(bool, true)
    workflows                      = list(string)
  })
  default = {
    enabled                        = false
    enable_wif_attribute_condition = true
    workflows                      = ["guardian-admin.yml", "guardian-apply.yml", "guardian-plan.yml"]
  }
}

variable "github" {
  description = "The GitHub repository information."
  type = object({
    owner_name     = string
    owner_id       = string
    repo_name      = string
    repo_id        = string
    default_branch = optional(string, "main")
  })
}

variable "override_wif_attribute_mapping" {
  type        = map(string)
  description = "(Optional) Override the Workload Identity Federation provider attribute mappings. Defaults to base mapping for default attribute condition."
  default     = null
}

variable "override_wif_attribute_condition" {
  type        = string
  description = "(Optional) Override the Workload Identity Federation provider attribute condition. Appended to base condition, matching GitHub owner and repository id."
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
