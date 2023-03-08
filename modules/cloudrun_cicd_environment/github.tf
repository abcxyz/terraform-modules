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

resource "github_repository_environment" "default" {
  # This is just the repo name without the org name. The org name is implied by the github auth token.
  # There's no way to just specify the owner.
  repository  = var.svc.github_repository_name
  environment = var.environment_name

  reviewers {
    users = var.reviewer_user_github_ids
    teams = var.reviewer_team_github_ids
  }

  deployment_branch_policy {
    protected_branches     = var.protected_branches
    custom_branch_policies = var.custom_branch_policies
  }
}

resource "github_actions_environment_secret" "cloudrun_project_id_secret" {
  repository      = var.svc.github_repository_name
  environment     = var.environment_name
  secret_name     = "cloudrun_project_id"
  plaintext_value = google_project.project.project_id
}

resource "github_actions_environment_secret" "cloudrun_region_secret" {
  repository      = var.svc.github_repository_name
  environment     = var.environment_name
  secret_name     = "cloudrun_region"
  plaintext_value = var.cloudrun_region
}

resource "github_actions_environment_secret" "cloudrun_service_secret" {
  repository      = var.svc.github_repository_name
  environment     = var.environment_name
  secret_name     = "cloudrun_service"
  plaintext_value = module.cloud_run_service.service_name
}
