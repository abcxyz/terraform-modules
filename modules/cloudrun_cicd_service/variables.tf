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

variable "folder_id" {
  type        = string
  description = "The ID of the GCP folder in which to create projects."
}

variable "billing_account" {
  type        = string
  default     = null
  description = "GCP billing account to associate with GCP projects. Since company policy requires GCP projects to be created initially without a billing account and then associated with billing account by a human, this variable will usually be null."
}

variable "service_name" {
  type = string
  validation {
    condition     = can(regex("^[a-z][0-9a-z-]+[0-9a-z]$", var.service_name))
    error_message = "Name can only contain lowercase letters, numbers, hyphens(-) and must start with letter. Name will be truncated and suffixed with at random string if it exceeds requirements for a given resource."
  }
  description = "A string that identifies this service; it will be become part of the name of many of the created resources such as project names"
}

variable "github_owner_id" {
  type        = number
  description = "The GitHub ID of the owner (an organization or a user) that owns the GitHub repo containing the source code for this service"
}

variable "github_repository_id" {
  type        = number
  description = "The GitHub ID of the repository that owns the GitHub repo containing the source code for this service. Must be the same repo as github_repository_name."
}

variable "github_repository_name" {
  type        = string
  description = "The name of the GitHub repository containing the service's source code, not including the org/owner. Must be the same repo as github_repository_id."
}

variable "artifact_repository_location" {
  type        = string
  default     = "us"
  description = "The location to create the artifact registry repository (defaults to 'us')."
}
