# Copyright 2024 The Authors (see AUTHORS file)
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
  description = "The GCP project ID."
  type        = string
}

variable "cloud_run_resource" {
  description = "One of either service name or job name which will dictate the Cloud Run resource to monitor."
  type = object({
    service_name = optional(string)
    job_name     = optional(string)
  })
  validation {
    condition     = length([for k, v in var.cloud_run_resource : v if v != null]) == 1
    error_message = "Either service_name or job_name must be defined"
  }
}

variable "runbook_urls" {
  description = "URLs of markdown files."
  type = object({
    forward_progress = string
    cpu              = string
  })
  default = {
    forward_progress = ""
    cpu              = ""
  }
}

variable "built_in_forward_progress_indicators" {
  description = "Map for forward progress Cloud Run indicators. The window must be in seconds."
  type = map(object({
    metric = string
    window = number
  }))
}

variable "built_in_cpu_indicators" {
  description = "Map for CPU Cloud Run indicators. The window must be in seconds."
  type = map(object({
    metric    = string
    window    = number
    threshold = number
  }))
}

variable "log_based_text_indicators" {
  description = "Map for Cloud Run log based indicators. Only support text payload logs."
  type = map(object({
    log_name_suffix = string
    severity        = string
    textPayload     = string
  }))
  validation {
    condition = alltrue([
      for k, v in var.log_based_text_indicators :
      contains(["DEBUG", "INFO", "WARN", "ERROR"], v.severity)
    ])
    error_message = "The 'severity' field must be one of: 'DEBUG', 'INFO', 'WARN', 'ERROR'."
  }
}

variable "notification_channels" {
  description = "List of notification channels to alert."
  type        = list(string)
  default     = []
}
