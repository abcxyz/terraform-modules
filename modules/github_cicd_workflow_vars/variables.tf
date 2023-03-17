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

variable "github_repository_name" {
  type        = string
  description = "The name of the GitHub repository containing the service's source code, not including the org/owner. E.g. 'my-service'"
}

variable "wif_provider_name" {
  type        = string
  description = "The Workload Identity Federation provider name"
}

variable "infra_project_id" {
  type        = string
  description = "The GCP project ID that contains the Artifact Registry repository."
}

variable "service_account_email" {
  type        = string
  description = "CI service account identity in the form serviceAccount:{email}."
}

variable "artifact_repository_id" {
  type        = string
  description = "ID of the Artifact Registry repository containing docker images. E.g. 'my-image-repo'"
}

variable "artifact_repository_location" {
  type        = string
  description = "Location of the artifact registry repository. Either a region name or a multi-regional location name. E.g. 'us', 'us-west1'"
}

