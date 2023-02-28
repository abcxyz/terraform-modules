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

output "artifact_repository_name" {
  description = "The Artifact Registry name."
  value       = google_artifact_registry_repository.artifact_repository.name
}

output "artifact_repository_id" {
  description = "The Artifact Registry ID, e.g. ci-images"
  value       = google_artifact_registry_repository.artifact_repository.repository_id
}

output "artifact_repository_location" {
  description = "The Artifact Registry repository location, e.g. \"us\" or \"us-west1\""
  value       = google_artifact_registry_repository.artifact_repository.location
}

output "wif_pool_name" {
  description = "The Workload Identity Federation pool name."
  value       = google_iam_workload_identity_pool.github_pool.name
}

output "wif_provider_name" {
  description = "The Workload Identity Federation provider name."
  value       = google_iam_workload_identity_pool_provider.github_provider.name
}

output "service_account_email" {
  description = "CI service account identity email address."
  value       = google_service_account.ci_service_account.email
}

output "service_account_member" {
  description = "CI service account identity in the form serviceAccount:{email}."
  value       = google_service_account.ci_service_account.member
}
