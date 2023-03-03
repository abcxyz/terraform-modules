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

variable "service_name" {
  type = string
  validation {
    condition     = can(regex("^[a-z][0-9a-z-]+[0-9a-z]$", var.service_name))
    error_message = "Name can only contain lowercase letters, numbers, hyphens(-) and must start with letter. Name will be truncated and suffixed with at random string if it exceeds requirements for a given resource."
  }
  description = "A string that identifies this service; it will be become part of the name of many of the created resources such as project names"
}

variable "folder_id" {
  type        = string
  description = "The ID of the GCP folder in which to create projects."
}

variable "billing_account" {
  type        = string
  default     = null
  description = "GCP billing account to associate with GCP projects. Since company policy requires GCP projects to be created initially without a billing account and then associated with billing account by a human, this variable will usually be null."
}

variable "admin_project_id" {
  type        = string
  description = "The project ID of the GCP project that contains the artifact repository and WIF pool."
}

variable "github_repository_name" {
  type        = string
  description = "The name of the GitHub repository containing the service's source code, not including the org/owner."
}

variable "initial_container_image" {
  type        = string
  description = "The path of the docker image that will be served by Cloud Run until the first deployment."
  default     = "us-docker.pkg.dev/cloudrun/container/hello"
}

variable "cicd_service_account_email" {
  type        = string
  description = "The email address of the service account that the GitHub workflows will authenticate as."
}

variable "cloudrun_region" {
  type        = string
  description = "The GCP region where the Cloud Run service will run."
}

variable "environment_name" {
  type        = string
  description = "The GitHub environment name. It will also be included in some GCP resource names."
}

variable "protected_branches" {
  type        = bool
  default     = false
  description = "Whether this environment should only allow deployment from GitHub branches that have protection enabled"
}

variable "reviewer_user_github_ids" {
  type        = list(number)
  default     = null
  description = "A list of GitHub user IDs that will have permission to approve releases into this environment."
}

variable "reviewer_team_github_ids" {
  type        = list(number)
  default     = null
  description = "A list of GitHub team IDs whose members will have permission to approve releases into this environment."
}

variable "artifact_repository_location" {
  type        = string
  description = "The location to create the artifact registry repository (defaults to 'us')."
}

variable "artifact_repository_id" {
  type        = string
  description = "The ID of the GCP Artifact Registry repository holding container images for this service."

}

variable "environment_type" {
  type = string
  validation {
    condition     = contains(["prod", "non-prod"], var.environment_type)
    error_message = "environment type must be prod or non-prod"
  }
}
