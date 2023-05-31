#
# This module defines the default configuration for a github respository to
# enable automation capabilities using workload identity federation.
#

locals {
  repo_full_name = "${var.github.owner_name}/${var.github.repo_name}"

  default_wif_attribute_mapping = {
    "google.subject" : "assertion.sub"
    "attribute.actor" : "assertion.actor"
    "attribute.aud" : "assertion.aud"
    "attribute.event_name" : "assertion.event_name"
    "attribute.environment" : "assertion.environment"
    "attribute.repository" : "assertion.repository"
    "attribute.repository_id" : "assertion.repository_id"
    "attribute.repository_owner_id" : "assertion.repository_owner_id"
    "attribute.repository_visibility" : "assertion.repository_visibility"
    "attribute.workflow" : "assertion.workflow"
    "attribute.workflow_ref" : "assertion.workflow_ref"
  }

  # We create conditions based on ID instead of name to prevent name hijacking
  # or squatting attacks.
  #
  # We also prevent pull_request_target, since that runs arbitrary code:
  #   https://securitylab.github.com/research/github-actions-preventing-pwn-requests/
  default_wif_attribute_condition = trimspace(chomp(<<-EOF
      attribute.event_name != "pull_request_target"
       && attribute.repository_owner_id == "${var.github.owner_id}"
       && attribute.repository_id == "${var.github.repo_id}"
      EOF
  ))

  wif_attribute_mapping   = coalesce(var.wif_attribute_mapping, local.default_wif_attribute_mapping)
  wif_attribute_condition = coalesce(var.wif_attribute_condition, local.default_wif_attribute_condition)
}

resource "random_id" "default" {
  byte_length = 3
}

resource "google_project_service" "default" {
  for_each = toset([
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "serviceusage.googleapis.com",
    "sts.googleapis.com",
  ])

  project = var.project_id

  service                    = each.value
  disable_on_destroy         = false
  disable_dependent_services = false
}

resource "google_iam_workload_identity_pool" "default" {
  project = var.project_id

  workload_identity_pool_id = "gh-${var.id}-${random_id.default.hex}" # 32 characters
  display_name              = "GitHub WIF pool"                       # 32 characters
  description               = "GitHub OIDC identity pool (${local.repo_full_name}) - ${var.id}"

  depends_on = [
    google_project_service.default["iam.googleapis.com"],
  ]
}

resource "google_iam_workload_identity_pool_provider" "default" {
  project = var.project_id

  workload_identity_pool_id          = google_iam_workload_identity_pool.default.workload_identity_pool_id
  workload_identity_pool_provider_id = "gh-${var.id}-${random_id.default.hex}" # 32 characters
  display_name                       = "GitHub WIF Provider"                   # 32 characters
  description                        = "GitHub OIDC identity provider (${local.repo_full_name}) - ${var.id}"

  attribute_mapping   = local.wif_attribute_mapping
  attribute_condition = local.wif_attribute_condition

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

resource "google_service_account" "default" {
  project = var.project_id

  account_id   = "gh-${var.id}-sa" # 30 characters
  display_name = "GitHub WIF ${var.id} service account"
}

resource "google_service_account_iam_member" "default" {
  service_account_id = google_service_account.default.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.default.name}/*"
}
