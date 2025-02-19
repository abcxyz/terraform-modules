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
    forward_progress = optional(string)
    container_util   = optional(string)
    bad_request      = optional(string)
    server_fault     = optional(string)
    request_latency  = optional(string)
    max_conns        = optional(string)
    job_failure      = optional(string)
    text_based_logs  = optional(string)
    json_based_logs  = optional(string)
  })
}

variable "notification_channels_non_paging" {
  description = "List of notification channels to alert."
  type        = list(string)
  default     = []
}

variable "enable_built_in_forward_progress_indicators" {
  type        = bool
  description = "A flag to enable or disable the creation of built in forward progress indicators."
  default     = false
}

variable "built_in_forward_progress_indicators" {
  description = "Map for forward progress Cloud Run indicators. The window must be in seconds."
  type = map(object({
    metric                     = string
    window                     = number
    threshold                  = number
    additional_filters         = optional(string)
    additional_group_by_fields = optional(list(string))
  }))
  default = {}
}

variable "enable_built_in_container_indicators" {
  type        = bool
  description = "A flag to enable or disable the creation of built in container utilization indicators."
  default     = false
}

variable "built_in_container_util_indicators" {
  description = "Map for Cloud Run container utilization indicators. The window must be in seconds. Threshold should be represented "
  type = map(object({
    metric                     = string
    window                     = number
    threshold                  = number
    p_value                    = optional(number)
    additional_filters         = optional(string)
    additional_group_by_fields = optional(list(string))
  }))
  default = {}
}

variable "enable_log_based_text_indicators" {
  type        = bool
  description = "A flag to enable or disable the creation of log based text indicators."
  default     = false
}

variable "log_based_text_indicators" {
  description = "Map for log based indicators using text payload. Payload message is a regex match."
  type = map(object({
    log_name_suffix      = string
    severity             = string
    text_payload_message = string
    condition_threshold = object({
      window    = number
      threshold = number
    })
    additional_filters         = optional(string)
    additional_group_by_fields = optional(list(string))
  }))
  validation {
    condition = alltrue([
      for k, v in var.log_based_text_indicators :
      contains(["DEBUG", "INFO", "WARNING", "ERROR"], v.severity)
    ])
    error_message = "The 'severity' field must be one of: 'DEBUG', 'INFO', 'WARNING', 'ERROR'."
  }
  default = {}
}

variable "enable_log_based_json_indicators" {
  type        = bool
  description = "A flag to enable or disable the creation of log based JSON indicators."
  default     = false
}

variable "log_based_json_indicators" {
  description = "Map for log based indicators using JSON payload. Payload message is a regex match."
  type = map(object({
    log_name_suffix = string
    severity        = string
    condition_threshold = object({
      window    = number
      threshold = number
    })
    additional_filters         = optional(string)
    additional_group_by_fields = optional(list(string))
  }))
  validation {
    condition = alltrue([
      for k, v in var.log_based_json_indicators :
      contains(["DEBUG", "INFO", "WARNING", "ERROR"], v.severity)
    ])
    error_message = "The 'severity' field must be one of: 'DEBUG', 'INFO', 'WARNING', 'ERROR'."
  }
  default = {}
}

variable "service_4xx_configuration" {
  description = "Configuration applied to the 4xx alert policy. Only applies to services."
  type = object({
    enabled                    = bool
    window                     = number
    threshold                  = number
    additional_filters         = optional(string)
    additional_group_by_fields = optional(list(string))
  })
  default = {
    enabled                    = false
    window                     = 300
    threshold                  = 0
    additional_filters         = ""
    additional_group_by_fields = []
  }
}

variable "service_5xx_configuration" {
  description = "Configuration applied to the 5xx alert policy. Only applies to services."
  type = object({
    enabled                    = bool
    window                     = number
    threshold                  = number
    additional_filters         = optional(string)
    additional_group_by_fields = optional(list(string))
  })
  default = {
    enabled                    = false
    window                     = 300
    threshold                  = 0
    additional_filters         = ""
    additional_group_by_fields = []
  }
}

variable "service_latency_configuration" {
  description = "Configuration applied to the request latency alert policy. Only applies to services."
  type = object({
    enabled                    = bool
    window                     = number
    threshold_ms               = number
    p_value                    = number
    additional_filters         = optional(string)
    additional_group_by_fields = optional(list(string))
  })
  default = {
    enabled                    = false
    window                     = 300
    threshold_ms               = 0
    p_value                    = 95
    additional_filters         = ""
    additional_group_by_fields = []
  }
  validation {
    condition     = contains([50, 95, 99], var.service_latency_configuration.p_value)
    error_message = "The 'p_value' field must be one of: 50, 95, 99."
  }
}

variable "service_max_conns_configuration" {
  description = "Configuration applied to the max connections alert policy. Only applies to services."
  type = object({
    enabled                    = bool
    window                     = number
    threshold                  = number
    p_value                    = number
    additional_filters         = optional(string)
    additional_group_by_fields = optional(list(string))
  })
  default = {
    enabled                    = false
    window                     = 300
    threshold                  = 0
    p_value                    = 95
    additional_filters         = ""
    additional_group_by_fields = []
  }
  validation {
    condition     = contains([50, 95, 99], var.service_max_conns_configuration.p_value)
    error_message = "The 'p_value' field must be one of: 50, 95, 99."
  }
}

variable "job_failure_configuration" {
  description = "Configuration applied to the job failure alert policy. Only applies to jobs."
  type = object({
    enabled                    = bool
    window                     = number
    threshold                  = number
    additional_filters         = optional(string)
    additional_group_by_fields = optional(list(string))
  })
  default = {
    enabled                    = false
    window                     = 300
    threshold                  = 0
    additional_filters         = ""
    additional_group_by_fields = []
  }
}

variable "dashboard_json_files" {
  description = "Path to a dashboard configuration JSON files"
  type        = list(string)
}
