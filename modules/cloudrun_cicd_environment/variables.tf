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

variable "initial_container_image" {
  type        = string
  description = "The path of the docker image that will be served by Cloud Run until the first deployment."
  default     = "us-docker.pkg.dev/cloudrun/container/hello"
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

variable "environment_type" {
  type    = string
  default = "non-prod"
  validation {
    condition     = contains(["prod", "non-prod"], var.environment_type)
    error_message = "environment type must be prod or non-prod"
  }
}

variable "min_cloudrun_instances" {
  type        = number
  default     = 3
  description = "The minimum number of Cloud Run containers for this environment. >=3 is recommended for uptime."
}

variable "max_cloudrun_instances" {
  type        = number
  default     = 50 # Chosen arbitrarily, can be changed
  description = "The maximum number of Cloud Run containers for this environment, to avoid runaway costs under heavy load"
}

variable "svc" {
  description = "The object returned from cloudrun_cicd containing various identifiers for this service; this saves copypasta compared to passing them one by one"
  type = object({
    folder_id                    = string
    billing_account              = string
    admin_project_id             = string
    cicd_service_account_email   = string
    github_repository_name       = string
    service_name                 = string
    artifact_repository_location = string
    artifact_repository_id       = string
  })
}
