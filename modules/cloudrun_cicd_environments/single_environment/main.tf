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

resource "google_project" "project" {
  name       = "${var.service_name} ${var.environment_name}"
  project_id = "${var.service_name}-${var.environment_name}"

  folder_id       = var.folder_id
  billing_account = var.billing_account

  lifecycle {
    # We expect billing_account association to be done by a human after project creation in the common case.
    ignore_changes = [billing_account]
  }
}

resource "google_project_service" "default" {
  depends_on = [
    google_project.project
  ]
  for_each = toset([
    "iam.googleapis.com",
    "run.googleapis.com",
  ])
  service = each.value
  project = google_project.project.project_id
}

resource "google_service_account" "cloudrun_service_account" {
  depends_on   = [google_project_service.default]
  account_id   = "${var.service_name}-${var.environment_name}-sa"
  display_name = "${var.service_name} ${var.environment_name} SA"
  project      = google_project.project.project_id
}

resource "google_service_account_iam_member" "impersonate" {
  service_account_id = google_service_account.cloudrun_service_account.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${var.cicd_service_account_email}"
}

module "cloud_run_service" {
  source                = "github.com/abcxyz/terraform-modules/modules/cloud_run"
  project_id            = google_project.project.project_id
  region                = var.cloudrun_region
  name                  = var.service_name
  min_instances         = 3
  ingress               = var.environment_type == "prod" ? "all" : "internal"
  image                 = var.initial_container_image
  service_account_email = google_service_account.cloudrun_service_account.email
  service_iam = {
    developers = ["serviceAccount:${var.cicd_service_account_email}"]
    admins     = []
    invokers   = []
  }
}

# The Cloud Run Service Agent must have read access to the GAR repo. 
resource "google_artifact_registry_repository_iam_member" "cloudrun_sa_gar_reader" {
  project    = var.admin_project_id
  location   = var.artifact_repository_location
  repository = var.artifact_repository_id
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:service-${google_project.project.number}@serverless-robot-prod.iam.gserviceaccount.com"
  depends_on = [
    module.cloud_run_service
  ]
}

resource "github_repository_environment" "default" {
  environment = var.environment_name
  # This is just the repo name without the org name. The org name is implied by the github auth token.
  # There's no way to just specify the owner.
  repository = var.github_repository_name
  reviewers {
    users = var.reviewer_user_github_ids
    teams = var.reviewer_team_github_ids
  }

  # We only want a deployment_branch_policy for production environments.
  dynamic "deployment_branch_policy" {
    for_each = var.environment_type == "prod" ? [1] : []
    content {
      protected_branches     = true
      custom_branch_policies = true
    }
  }
}

resource "github_actions_environment_secret" "cloudrun_project_id_secret" {
  repository      = var.github_repository_name
  environment     = var.environment_name
  secret_name     = "cloudrun_project_id"
  plaintext_value = google_project.project.project_id
}

resource "github_actions_environment_secret" "cloudrun_region_secret" {
  repository      = var.github_repository_name
  environment     = var.environment_name
  secret_name     = "cloudrun_region"
  plaintext_value = var.cloudrun_region
}

resource "github_actions_environment_secret" "cloudrun_service_secret" {
  repository      = var.github_repository_name
  environment     = var.environment_name
  secret_name     = "cloudrun_service"
  plaintext_value = module.cloud_run_service.service_name
}
