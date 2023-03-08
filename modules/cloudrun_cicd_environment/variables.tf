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

variable "cloudrun_ingress" {
  type        = string
  default     = "all"
  description = "The ingress settings for the Cloud Run service, possible values: all, internal, internal-and-cloud-load-balancing (defaults to 'all')."
}

variable "cloudrun_invokers" {
  type        = list(string)
  description = "The list of IAM members who can access the Cloud Run service. examples: allUsers, serviceAccount:foo@bar"
}

variable "protected_branches" {
  type        = bool
  description = "Whether only GitHub branches with branch protection rules can deploy to this environment. See https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_environment."
}

variable "custom_branch_policies" {
  type        = bool
  description = "Whether only GitHub branches that match the specified name patterns can deploy to this environment. See https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_environment."
}
