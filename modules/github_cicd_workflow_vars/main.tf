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

resource "github_actions_variable" "wif_provider" {
  repository    = var.github_repository_name # Excludes org name, which is implied by the access token.
  variable_name = "wif_provider"
  value         = var.wif_provider_name
}

resource "github_actions_variable" "wif_service_account" {
  repository    = var.github_repository_name
  variable_name = "wif_service_account"
  value         = var.service_account_email
}

resource "github_actions_variable" "infra_project_id" {
  repository    = var.github_repository_name
  variable_name = "infra_project_id"
  value         = var.infra_project_id
}

resource "github_actions_variable" "gar_location" {
  repository    = var.github_repository_name
  variable_name = "gar_location"
  value         = var.artifact_repository_location
}

resource "github_actions_variable" "gar_repo_id" {
  repository    = var.github_repository_name
  variable_name = "gar_repo_id"
  value         = var.artifact_repository_id
}

resource "github_actions_environment_variable" "project_id_for_env" {
  for_each = var.environment_projects

  repository    = var.github_repository_name
  variable_name = "project_id_for_env"
  environment   = each.key
  value         = each.value
}
