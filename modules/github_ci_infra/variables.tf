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

variable "github_owner_id" {
  type        = number
  description = "The GitHub ID of the owner of the repository whose workflows will be granted access to the WIF pool (i.e. an organization ID or user ID)."
}

variable "github_repository_id" {
  type        = number
  description = "The GitHub ID of the repository whose workflows will be granted access to the WIF pool."
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
