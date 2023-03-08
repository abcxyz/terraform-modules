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

# Create the WIF pool, artifact registry, and service account.
module "github_ci_access_config" {
  source = "git::https://github.com/abcxyz/terraform-modules.git//modules/github_ci_infra?ref=41836e2b91baa1a7552b41f76fb9a8f261ae7dbe"

  project_id             = google_project.admin_project.project_id
  github_repository_id   = var.github_repository_id
  github_owner_id        = var.github_owner_id
  name                   = var.service_name
  registry_repository_id = substr("${var.service_name}-images", 0, 63)
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
  plaintext_value = module.github_ci_access_config.artifact_repository_id
}
