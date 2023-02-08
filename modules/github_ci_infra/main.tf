# Copyright 2023 The Authors (see AUTHORS file)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

locals {
  github_owner_name = "abcxyz"
}

resource "random_id" "default" {
  byte_length = 2
}

data "github_organization" "owner" {
  name = local.github_owner_name
}

data "github_repository" "repo" {
  full_name = "${local.github_owner_name}/${var.github_repository_name}"
}

# Project Services
resource "google_project_service" "services" {
  for_each = toset([
    "artifactregistry.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "serviceusage.googleapis.com",
    "sts.googleapis.com",
  ])

  project                    = var.project_id
  service                    = each.value
  disable_on_destroy         = false
  disable_dependent_services = false
}

# Artifact Registry
resource "google_artifact_registry_repository" "artifact_repository" {
  location      = var.registry_location
  project       = var.project_id
  repository_id = var.registry_repository_id
  description   = "Container registry for docker images."
  format        = "DOCKER"

  depends_on = [
    google_project_service.services["artifactregistry.googleapis.com"],
  ]
}

resource "google_artifact_registry_repository_iam_binding" "ci_service_account_iam" {
  project    = google_artifact_registry_repository.artifact_repository.project
  location   = google_artifact_registry_repository.artifact_repository.location
  repository = google_artifact_registry_repository.artifact_repository.name
  role       = "roles/artifactregistry.repoAdmin"
  members    = toset(["serviceAccount:${google_service_account.ci_service_account.email}"])
}

# Workload Identity Federation - currently only allowed in abcxyz org
resource "google_iam_workload_identity_pool" "github_pool" {
  project                   = var.project_id
  workload_identity_pool_id = "github-pool-${random_id.default.hex}"
  display_name              = "GitHub WIF Pool"
  description               = "Identity pool for CI environment"

  depends_on = [
    google_project_service.services["iam.googleapis.com"],
  ]
}

resource "google_iam_workload_identity_pool_provider" "github_provider" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "GitHub WIF Provider"
  description                        = "GitHub OIDC identity provider for ${data.github_repository.repo.full_name} CI environment"
  attribute_mapping = {
    "google.subject" : "assertion.sub"
    "attribute.actor" : "assertion.actor"
    "attribute.aud" : "assertion.aud"
    "attribute.event_name" : "assertion.event_name"
    "attribute.repository_owner_id" : "assertion.repository_owner_id"
    "attribute.repository" : "assertion.repository"
    "attribute.repository_id" : "assertion.repository_id"
    "attribute.workflow" : "assertion.workflow"
  }

  # We create conditions based on ID instead of name to prevent name hijacking
  # or squatting attacks.
  #
  # We also prevent pull_request_target, since that runs arbitrary code:
  #   https://securitylab.github.com/research/github-actions-preventing-pwn-requests/
  attribute_condition = "attribute.event_name != \"pull_request_target\" && attribute.repository_owner_id == \"${data.github_organization.owner.id}\" && attribute.repository_id == \"${data.github_repository.repo.repo_id}\""

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  depends_on = [
    google_iam_workload_identity_pool.github_pool
  ]
}

resource "google_service_account" "ci_service_account" {
  project      = var.project_id
  account_id   = "${substr(var.name, 0, 19)}-${random_id.default.hex}-ci-sa" # 30 character limit
  display_name = "${var.name} CI Service Account"
}

resource "google_service_account_iam_member" "wif_github_iam" {
  service_account_id = google_service_account.ci_service_account.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/*"
}
