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

resource "google_project" "admin_project" {
  name            = "${var.service_name} admin"
  project_id      = "${var.service_name}-admin"
  folder_id       = var.folder_id
  billing_account = var.billing_account

  lifecycle {
    # We expect billing_account association to be done by a human after project creation in the common case.
    ignore_changes = [billing_account]
  }
}

resource "google_project_service" "admin_enabled_services" {
  for_each = toset([
    "iam.googleapis.com",
    "compute.googleapis.com",
  ])
  service = each.value
  project = google_project.admin_project.project_id
}

# Create the WIF pool, artifact registry, and service account.
module "github_ci_access_config" {
  source                 = "github.com/abcxyz/terraform-modules/modules/github_ci_infra"
  project_id             = google_project.admin_project.project_id
  github_repository_id   = var.github_repository_id
  github_owner_id        = var.github_owner_id
  name                   = var.service_name
  registry_repository_id = var.service_name
  registry_location      = var.artifact_repository_location
  depends_on = [
    google_project_service.admin_enabled_services
  ]
}

resource "github_actions_secret" "wif_provider_secret" {
  repository      = var.github_repository_name # Excludes org name, which is implied by the access token.
  secret_name     = "wif_provider"
  plaintext_value = module.github_ci_access_config.wif_provider_name
}

resource "github_actions_secret" "wif_service_account_secret" {
  repository      = var.github_repository_name
  secret_name     = "wif_service_account"
  plaintext_value = module.github_ci_access_config.service_account_email
}

resource "github_actions_secret" "admin_project_id_secret" {
  repository      = var.github_repository_name
  secret_name     = "admin_project_id"
  plaintext_value = google_project.admin_project.project_id
}

resource "github_actions_secret" "docker_image_secret" {
  repository      = var.github_repository_name
  secret_name     = "docker_image"
  plaintext_value = var.service_name
}

resource "github_actions_secret" "gar_location_secret" {
  repository      = var.github_repository_name
  secret_name     = "gar_location"
  plaintext_value = module.github_ci_access_config.artifact_repository_location
}

resource "github_actions_secret" "gar_repo_id_secret" {
  repository      = var.github_repository_name
  secret_name     = "gar_repo_id"
  plaintext_value = var.service_name
}

module "env" {
  for_each = {
    for index, de in var.deployment_environments :
    de.environment_name => de
  }

  source                       = "./single_environment"
  folder_id                    = var.folder_id
  billing_account              = var.billing_account
  admin_project_id             = google_project.admin_project.project_id
  cicd_service_account_email   = module.github_ci_access_config.service_account_email
  github_repository_name       = var.github_repository_name
  service_name                 = var.service_name
  artifact_repository_location = module.github_ci_access_config.artifact_repository_location
  artifact_repository_id       = module.github_ci_access_config.artifact_repository_id
  environment_name             = each.key
  environment_type             = each.value.environment_type
  cloudrun_region              = each.value.cloudrun_region
  reviewer_team_github_ids     = each.value.reviewer_team_github_ids
  reviewer_user_github_ids     = each.value.reviewer_user_github_ids
}
