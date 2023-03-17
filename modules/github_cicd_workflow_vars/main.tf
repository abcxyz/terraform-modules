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

resource "github_actions_secret" "wif_provider_secret" {
  repository      = var.github_repository_name # Excludes org name, which is implied by the access token.
  secret_name     = "wif_provider"
  plaintext_value = var.wif_provider_name
}

resource "github_actions_secret" "wif_service_account_secret" {
  repository      = var.github_repository_name
  secret_name     = "wif_service_account"
  plaintext_value = var.service_account_email
}

resource "github_actions_secret" "infra_project_id_secret" {
  repository      = var.github_repository_name
  secret_name     = "infra_project_id"
  plaintext_value = var.infra_project_id
}

resource "github_actions_secret" "gar_location_secret" {
  repository      = var.github_repository_name
  secret_name     = "gar_location"
  plaintext_value = var.artifact_repository_location
}

resource "github_actions_secret" "gar_repo_id_secret" {
  repository      = var.github_repository_name
  secret_name     = "gar_repo_id"
  plaintext_value = var.artifact_repository_id
}
