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

variable "project_id" {
  type        = string
  description = "The Google Cloud project ID."
}

variable "name" {
  type        = string
  description = "The name of this project."
  validation {
    condition     = can(regex("^[a-z][0-9a-z-]+[0-9a-z]$", var.name))
    error_message = "Name can only contain lowercase letters, numbers, hyphens(-) and must start with letter. Name will be truncated and suffixed with at random string if it exceeds requirements for a given resource."
  }
}

variable "github_owner_name" {
  type        = string
  description = "The GitHub owner name to grant access to the WIF pool GitHub provider (e.g. organization)."
}

variable "github_owner_id" {
  type = string
  default = null
  description = "The GitHub owner ID to grant access to the WIF pool. This can be omitted if github_owner_name is an organization. Otherwise, (say if github_owner_name is a username and not an org), then this must be provided. It can be found at https://api.github.com/users/$USERNAME ."
}

variable "github_repository_name" {
  type        = string
  description = "The GitHub repository name to grant access to the WIF pool GitHub provider (e.g. repo-name)."
}

variable "registry_repository_id" {
  type        = string
  default     = "ci-images"
  description = "The id of the artifact registry repository to be created (defaults to 'ci-images')."
}

variable "registry_location" {
  type        = string
  default     = "us"
  description = "The location to create the artifact registry repository (defaults to 'us')."
}
