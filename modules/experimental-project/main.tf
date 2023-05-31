#
# This module defines the default configuration for a developer to have a
# playground. It creates a project with environment:experimental tags.
#

locals {
  project_id = coalesce(var.project_id, "${var.short_name}-${random_id.default.hex}") # limit 30 characters
}

resource "random_id" "default" {
  byte_length = 3
}

resource "google_project" "default" {
  folder_id  = var.parent
  project_id = local.project_id

  name            = local.project_id
  billing_account = var.billing_account
}

resource "google_project_service" "default" {
  for_each = toset([
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "serviceusage.googleapis.com",
  ])

  project = google_project.default.project_id

  service                    = each.value
  disable_on_destroy         = false
  disable_dependent_services = false
}

resource "google_project_iam_member" "default" {
  project = google_project.default.project_id

  role   = "roles/resourcemanager.projectIamAdmin"
  member = var.owner

  depends_on = [
    google_project_service.default["iam.googleapis.com"]
  ]
}

resource "google_resource_manager_lien" "default" {
  parent       = google_project.default.id
  restrictions = ["resourcemanager.projects.delete"]
  origin       = "managed-by-terraform"
  reason       = "This project is managed by Terraform. Please delete via your Terraform configuration."
}
