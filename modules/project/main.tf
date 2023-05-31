#
# This module defines the default configuration for a new project
# for a product.
#

locals {
  project_id = var.enable_suffix ? "${substr(var.project_id, 0, 23)}-${random_id.default.hex}" : substr(var.project_id, 0, 30) # limit 30 characters

  default_project_services = [
    "cloudresourcemanager.googleapis.com",
    "serviceusage.googleapis.com",
  ]
}

resource "null_resource" "project_id_validation" {
  lifecycle {
    precondition {
      condition     = var.enable_suffix ? length(var.project_id) <= 23 : true
      error_message = "ERROR: project_id must be <= 23 characters with suffix enabled."
    }
    precondition {
      condition     = var.enable_suffix ? true : length(var.project_id) <= 30
      error_message = "ERROR: project_id must be <= 30 characters with suffix disabled."
    }
  }
}

resource "random_id" "default" {
  byte_length = 3
}

resource "google_project" "default" {
  folder_id  = var.folder_name
  project_id = local.project_id

  name            = local.project_id
  billing_account = var.billing_account
}

resource "google_project_service" "default" {
  for_each = toset(concat(local.default_project_services, var.project_services))

  project = google_project.default.project_id

  service                    = each.value
  disable_on_destroy         = false
  disable_dependent_services = false
}

resource "google_resource_manager_lien" "default" {
  count = var.enable_project_lien ? 1 : 0

  parent       = google_project.default.id
  restrictions = ["resourcemanager.projects.delete"]
  origin       = "managed-by-terraform"
  reason       = "This project is managed by Terraform. Please delete via your Terraform configuration."
}
