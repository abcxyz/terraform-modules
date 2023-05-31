#
# This module defines the default configuration for a new product.
#

locals {
  team_group_non_privileged_roles = toset(["roles/editor", "roles/resourcemanager.folderViewer"])
  team_group_privileged_roles     = toset(["roles/browser", "roles/resourcemanager.folderViewer"])
  breakglass_group_roles          = toset(["roles/editor", "roles/resourcemanager.folderViewer"])

  valid_product_environments = [for k, v in var.org_product_environments : k]
  privileged                 = lookup(try(var.org_product_environments[var.environment_id], {}), "privileged", false)
}

resource "null_resource" "environment_validation" {
  lifecycle {
    precondition {
      condition     = contains(local.valid_product_environments, var.environment_id)
      error_message = "ERROR: Invalid environment `${var.environment_id}`, valid environments are [`${join("`, `", local.valid_product_environments)}`]"
    }
  }
}

resource "google_folder" "default" {
  display_name = var.environment_id
  parent       = var.product_folder_name

  depends_on = [null_resource.environment_validation]
}

resource "google_tags_tag_binding" "default" {
  parent    = "//cloudresourcemanager.googleapis.com/${google_folder.default.name}"
  tag_value = var.org_tag_values["environment:${var.environment_id}"].id

  depends_on = [null_resource.environment_validation]
}

resource "google_folder_iam_member" "environment_team_non_privileged" {
  for_each = local.privileged ? [] : local.team_group_non_privileged_roles

  folder = google_folder.default.name
  role   = each.value
  member = "group:${var.team_group_email}"
}

resource "google_folder_iam_member" "environment_team_privileged" {
  for_each = local.privileged ? local.team_group_privileged_roles : []

  folder = google_folder.default.name
  role   = each.value
  member = "group:${var.team_group_email}"
}

resource "google_folder_iam_member" "environment_breakglass" {
  for_each = local.privileged ? local.breakglass_group_roles : []

  folder = google_folder.default.name
  role   = each.value
  member = "group:${var.breakglass_group_email}"
}
