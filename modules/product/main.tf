#
# This module defines the default configuration for a new product.
#

locals {
  environments_map = {
    for e in var.environments : e => e
  }
}

resource "google_folder" "product" {
  display_name = var.product_id
  parent       = var.parent_name
}

resource "google_folder_iam_member" "product_team_iam" {
  for_each = toset(["roles/resourcemanager.folderViewer"])

  folder = google_folder.product.name
  role   = each.value
  member = "group:${var.team_group_email}"
}

resource "google_tags_tag_value" "product" {
  parent     = local.remote_state.org_tags.org_tag_keys.product.id
  short_name = var.product_id
}

resource "google_tags_tag_binding" "product" {
  parent    = "//cloudresourcemanager.googleapis.com/${google_folder.product.name}"
  tag_value = google_tags_tag_value.product.id
}

module "environments" {
  for_each = local.environments_map

  source = "./modules/environment"

  product_folder_name    = google_folder.product.name
  environment_id         = each.key
  team_group_email       = var.team_group_email
  breakglass_group_email = var.breakglass_group_email

  org_product_environments = local.remote_state.org.product_environments
  org_tag_keys             = local.remote_state.org_tags.org_tag_keys
  org_tag_values           = local.remote_state.org_tags.org_tag_values
}
