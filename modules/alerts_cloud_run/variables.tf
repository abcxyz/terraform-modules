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

variable "enable_advanced_log_based_json_indicators" {
  type        = bool
  description = "A flag to enable or disable the creation of advanced log based JSON indicators."
  default     = false
}

variable "advanced_log_based_json_indicators" {
  description = "Map for advanced log based indicators using JSON payload with custom label extractors, metric descriptors, and alert conditions."
  type = map(object({
    name             = string
    description      = optional(string)
    filter           = string
    label_extractors = map(string)
    metric_kind      = string
    value_type       = string
    labels = list(object({
      key         = string
      value_type  = string
      description = string
    }))
    alert_condition = object({
      duration        = string
      threshold       = number
      aligner         = string
      reducer         = string
      filter          = optional(string)
      group_by_fields = optional(list(string))
      # Policy name allows custom policy name
      policy_name = optional(string)
      # Policy severity allows custom severity
      policy_severity = optional(string, "ERROR")
      # Runbook URL for this specific policy
      runbook_url = optional(string)
      # Policy group to include this metric in (if not specified, creates individual policy)
      policy_group = optional(string)
    })
  }))
  default = {}

  # Validations inspired by:
  # - Log severity levels: https://cloud.google.com/logging/docs/reference/v2/rest/v2/LogEntry#logseverity
  # - Metric naming conventions: https://cloud.google.com/logging/docs/logs-based-metrics/naming-restrictions
  # - Metric kinds and value types: https://cloud.google.com/monitoring/api/ref_v3/rest/v3/projects.metricDescriptors

  # Validation for metric_kind
  validation {
    condition = alltrue([
      for k, v in var.advanced_log_based_json_indicators :
      contains(["GAUGE", "DELTA", "CUMULATIVE"], v.metric_kind)
    ])
    error_message = "The 'metric_kind' field must be one of: 'GAUGE', 'DELTA', 'CUMULATIVE'."
  }

  # Validation for value_type
  validation {
    condition = alltrue([
      for k, v in var.advanced_log_based_json_indicators :
      contains(["BOOL", "INT64", "DOUBLE", "STRING", "DISTRIBUTION", "MONEY"], v.value_type)
    ])
    error_message = "The 'value_type' field must be one of: 'BOOL', 'INT64', 'DOUBLE', 'STRING', 'DISTRIBUTION', 'MONEY'."
  }

  # Validation for policy_severity
  validation {
    condition = alltrue([
      for k, v in var.advanced_log_based_json_indicators :
      v.alert_condition.policy_severity == null ||
      contains(["INFO", "WARNING", "ERROR", "CRITICAL"], v.alert_condition.policy_severity)
    ])
    error_message = "The 'policy_severity' must be one of: 'INFO', 'WARNING', 'ERROR', 'CRITICAL'."
  }

  # Validation for metric name
  validation {
    condition = alltrue([
      for k, v in var.advanced_log_based_json_indicators :
      can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", v.name)) &&
      length(v.name) <= 100
    ])
    error_message = "Metric name must start with a letter, contain only alphanumeric characters and underscores, and be <= 100 chars."
  }

  # Separate validation for description
  validation {
    condition = alltrue([
      for k, v in var.advanced_log_based_json_indicators :
      v.description == null ? true : length(v.description) <= 256
    ])
    error_message = "Description must be <= 256 chars."
  }

  # Validation for keys and label names
  validation {
    condition = alltrue([
      for k, v in var.advanced_log_based_json_indicators : (
        can(regex("^[a-zA-Z0-9-_]+$", k)) &&
        length(keys(v.label_extractors)) == length(distinct(keys(v.label_extractors))) &&
        alltrue([for label_key in keys(v.label_extractors) : can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", label_key))]) &&
        alltrue([for label in v.labels : can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", label.key))])
      )
    ])
    error_message = <<-EOT
      Validation failed for advanced_log_based_json_indicators:
      - Indicator keys must contain only alphanumeric characters, dashes, or underscores.
      - Label keys must be unique, start with a letter, and contain only alphanumeric characters and underscores.
      - All label keys must be valid Google Cloud label names.
    EOT
  }

  # Validation for alert conditions
  validation {
    condition = alltrue([
      for k, v in var.advanced_log_based_json_indicators : (
        can(regex("^[0-9]+[smhd]$", v.alert_condition.duration)) &&
        v.alert_condition.threshold >= 0 &&
        (v.alert_condition.policy_name == null || can(regex("^[a-zA-Z0-9-_ ]+$", v.alert_condition.policy_name))) &&
        (v.alert_condition.policy_group == null || can(regex("^[a-zA-Z0-9-_]+$", v.alert_condition.policy_group)))
      )
    ])
    error_message = <<-EOT
      Validation failed for alert_condition:
      - duration must be a value like "60s", "5m", "1h", or "1d".
      - threshold must be zero or positive.
      - policy_name (if provided) must contain only alphanumeric characters, spaces, dashes, or underscores.
      - policy_group (if provided) must contain only alphanumeric characters, dashes, or underscores.
    EOT
  }

  # Validation for label consistency
  validation {
    condition = alltrue([
      for k, v in var.advanced_log_based_json_indicators : (
        length(v.labels) > 0 &&
        length(v.labels) == length(v.label_extractors) &&
        alltrue([for label in v.labels : contains(keys(v.label_extractors), label.key)])
      )
    ])
    error_message = <<-EOT
      Validation failed for label consistency:
      - At least one label must be defined.
      - Each label must have a corresponding label_extractor.
      - Each label_extractor must have a corresponding label definition.
    EOT
  }

  # Validation for aligners and reducers
  validation {
    condition = alltrue([
      for k, v in var.advanced_log_based_json_indicators : (
        can(regex("^ALIGN_[A-Z_]+$", v.alert_condition.aligner)) &&
        can(regex("^REDUCE_[A-Z_]+$", v.alert_condition.reducer))
      )
    ])
    error_message = <<-EOT
      Validation failed for aligner and reducer:
      - aligner must start with "ALIGN_" followed by uppercase letters and underscores.
      - reducer must start with "REDUCE_" followed by uppercase letters and underscores.
    EOT
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
