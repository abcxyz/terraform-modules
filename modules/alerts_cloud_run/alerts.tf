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

locals {
  metric_root = "run.googleapis.com"
  is_job      = var.cloud_run_resource.job_name != null

  metric_root_prefix = local.is_job ? "${local.metric_root}/job" : local.metric_root

  user_metric_root_prefix = "logging.googleapis.com/user"

  resource_type  = local.is_job ? "cloud_run_job" : "cloud_run_revision"
  resource_label = local.is_job ? "job_name" : "service_name"
  resource_value = local.is_job ? var.cloud_run_resource.job_name : var.cloud_run_resource.service_name

  default_group_by_fields = ["resource.label.location"]

  second = 1
  minute = 60 * local.second
  hour   = 60 * local.minute
  day    = 24 * local.hour
}

# Common forward progress #

resource "google_monitoring_alert_policy" "forward_progress_alert_policy" {
  project = var.project_id

  display_name = "ForwardProgress-${local.resource_value}"
  combiner     = "OR"

  dynamic "conditions" {
    for_each = var.built_in_forward_progress_indicators

    content {
      display_name = "${conditions.key} failing"

      condition_threshold {
        filter = <<-EOT
          metric.type="${local.metric_root_prefix}/${conditions.value.metric}" 
          resource.type="${local.resource_type}"
          resource.label.${local.resource_label}="${local.resource_value}"
        EOT

        duration        = "${conditions.value.window}s"
        comparison      = "COMPARISON_LT"
        threshold_value = conditions.value.threshold

        aggregations {
          alignment_period     = "60s"
          per_series_aligner   = "ALIGN_DELTA"
          cross_series_reducer = "REDUCE_SUM"
          group_by_fields      = local.default_group_by_fields
        }

        trigger {
          count = conditions.value.consecutive_window_violations
        }
      }
    }
  }
  dynamic "conditions" {
    for_each = var.built_in_forward_progress_indicators

    content {
      display_name = "${conditions.key} missing"

      condition_absent {
        filter = <<-EOT
          metric.type="${local.metric_root_prefix}/${conditions.value.metric}" 
          resource.type="${local.resource_type}" 
          resource.label.${local.resource_label}="${local.resource_value}"
        EOT

        duration = "${conditions.value.window}s"

        aggregations {
          alignment_period     = "60s"
          per_series_aligner   = "ALIGN_DELTA"
          cross_series_reducer = "REDUCE_SUM"
          group_by_fields      = local.default_group_by_fields
        }
      }
    }
  }

  alert_strategy {
    auto_close = "${local.day}s"

    notification_channel_strategy {
      renotify_interval = "${local.day}s"
    }
  }

  documentation {
    content   = var.runbook_urls.forward_progress
    mime_type = "text/markdown"
  }

  notification_channels = var.notification_channels
}

# Common container utilization #

resource "google_monitoring_alert_policy" "container_util_alert_policy" {
  project = var.project_id

  display_name = "ContainerUtilization-${local.resource_value}"
  combiner     = "OR"

  dynamic "conditions" {
    for_each = var.built_in_container_util_indicators

    content {
      display_name = "${conditions.key} utilization high"

      condition_threshold {
        filter = <<-EOT
          metric.type="${local.metric_root}/${conditions.value.metric}" 
          resource.type="${local.resource_type}" 
          resource.label.${local.resource_label}="${local.resource_value}"
        EOT

        duration        = "${conditions.value.window}s"
        comparison      = "COMPARISON_GT"
        threshold_value = conditions.value.threshold

        aggregations {
          alignment_period     = "60s"
          per_series_aligner   = "ALIGN_PERCENTILE_${conditions.value.p_value}"
          cross_series_reducer = "REDUCE_PERCENTILE_${conditions.value.p_value}"
          group_by_fields      = local.default_group_by_fields
        }

        trigger {
          count = conditions.value.consecutive_window_violations
        }
      }
    }
  }

  alert_strategy {
    auto_close = "${local.day}s"

    notification_channel_strategy {
      renotify_interval = "${local.day}s"
    }
  }

  documentation {
    content   = var.runbook_urls.container_util
    mime_type = "text/markdown"
  }

  notification_channels = var.notification_channels
}

# Common log based #

resource "google_logging_metric" "text_payload_logging_metric" {
  for_each = var.log_based_text_indicators

  project = var.project_id

  name = "${local.resource_value}-${each.key}"

  filter = <<EOT
    resource.type=${local.resource_type}
    log_name="projects/${var.project_id}/logs/${local.metric_root}%2F${replace(each.value.log_name_suffix, "/", "%2F")}"
    severity=${each.value.severity}
    textPayload=~"${each.value.text_payload_message}"
    ${each.value.additional_filters != null ? each.value.additional_filters : ""}
  EOT

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    labels {
      key         = "location"
      value_type  = "STRING"
      description = "location of service"
    }
    labels {
      key         = "service_name"
      value_type  = "STRING"
      description = "name of service"
    }
  }

  label_extractors = {
    "location"     = "EXTRACT(resource.labels.location)"
    "service_name" = "EXTRACT(resource.labels.service_name)"
  }
}

resource "google_monitoring_alert_policy" "text_payload_logging_alert_policy" {
  for_each = var.log_based_text_indicators

  project = var.project_id

  display_name = "LogBasedText-${local.resource_value}-${each.key}"
  combiner     = "OR"

  conditions {
    display_name = "${each.key} logging high"

    dynamic "condition_matched_log" {
      for_each = each.value.condition_threshold == null ? [1] : []

      content {
        filter = <<EOT
            resource.type=${local.resource_type}
            log_name="projects/${var.project_id}/logs/${local.metric_root}%2F${replace(each.value.log_name_suffix, "/", "%2F")}"
            severity>=${each.value.severity}
            textPayload=~"${each.value.text_payload_message}"
            ${each.value.additional_filters != null ? each.value.additional_filters : ""}
          EOT

        label_extractors = {
          "revision_name" = "EXTRACT(resource.labels.revision_name)"
          "location"      = "EXTRACT(resource.labels.location)"
        }
      }
    }

    dynamic "condition_threshold" {
      for_each = each.value.condition_threshold != null ? [1] : []

      content {
        filter = <<-EOT
            metric.type="${local.user_metric_root_prefix}/${local.resource_value}-${conditions.key}" 
            resource.type="${local.resource_type}"
          EOT

        duration        = "${each.value.condition_threshold.window}s"
        comparison      = "COMPARISON_GT"
        threshold_value = each.value.condition_threshold.threshold

        aggregations {
          alignment_period     = "60s"
          per_series_aligner   = "ALIGN_DELTA"
          cross_series_reducer = "REDUCE_SUM"
          group_by_fields      = local.default_group_by_fields
        }

        trigger {
          count = each.value.condition_threshold.consecutive_window_violations
        }
      }
    }
  }

  alert_strategy {
    auto_close = "${local.day}s"

    notification_rate_limit {
      period = "${local.day}s"
    }
  }

  dynamic "documentation" {
    for_each = each.value.runbook_url != "" ? [1] : []
    content {
      content   = each.value.runbook_url
      mime_type = "text/markdown"
    }
  }

  notification_channels = var.notification_channels
}

resource "google_logging_metric" "json_payload_logging_metric" {
  for_each = var.log_based_json_indicators

  project = var.project_id

  name = "${local.resource_value}-${each.key}"

  filter = <<EOT
    resource.type=${local.resource_type}
    log_name="projects/${var.project_id}/logs/${local.metric_root}%2F${replace(each.value.log_name_suffix, "/", "%2F")}"
    severity=${each.value.severity}
    jsonPayload.message=~"${each.value.json_payload_message}"
    ${each.value.additional_filters != null ? each.value.additional_filters : ""}
  EOT

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    labels {
      key         = "location"
      value_type  = "STRING"
      description = "location of service"
    }
    labels {
      key         = "service_name"
      value_type  = "STRING"
      description = "name of service"
    }
  }

  label_extractors = {
    "location"     = "EXTRACT(resource.labels.location)"
    "service_name" = "EXTRACT(resource.labels.service_name)"
  }
}

resource "google_monitoring_alert_policy" "json_payload_logging_alert_policy" {
  for_each = var.log_based_json_indicators

  project = var.project_id

  display_name = "LogBasedJSON-${local.resource_value}-${each.key}"
  combiner     = "OR"

  conditions {
    display_name = "${each.key} logging high"

    dynamic "condition_matched_log" {
      for_each = each.value.condition_threshold == null ? [1] : []

      content {
        filter = <<EOT
            resource.type=${local.resource_type}
            log_name="projects/${var.project_id}/logs/${local.metric_root}%2F${replace(each.value.log_name_suffix, "/", "%2F")}"
            severity>=${each.value.severity}
            jsonPayload.message=~"${each.value.json_payload_message}"
            ${each.value.additional_filters != null ? each.value.additional_filters : ""}
          EOT

        label_extractors = {
          "revision_name" = "EXTRACT(resource.labels.revision_name)"
          "location"      = "EXTRACT(resource.labels.location)"
        }
      }
    }

    dynamic "condition_threshold" {
      for_each = each.value.condition_threshold != null ? [1] : []

      content {
        filter = <<-EOT
            metric.type="${local.user_metric_root_prefix}/${local.resource_value}-${each.key}" 
            resource.type="${local.resource_type}"
          EOT

        duration        = "${each.value.condition_threshold.window}s"
        comparison      = "COMPARISON_GT"
        threshold_value = each.value.condition_threshold.threshold

        aggregations {
          alignment_period     = "60s"
          per_series_aligner   = "ALIGN_DELTA"
          cross_series_reducer = "REDUCE_SUM"
          group_by_fields      = local.default_group_by_fields
        }

        trigger {
          count = each.value.condition_threshold.consecutive_window_violations
        }
      }
    }
  }

  alert_strategy {
    auto_close = "${local.day}s"

    notification_rate_limit {
      period = "${local.day}s"
    }
  }

  dynamic "documentation" {
    for_each = each.value.runbook_url != "" ? [1] : []
    content {
      content   = each.value.runbook_url
      mime_type = "text/markdown"
    }
  }

  notification_channels = var.notification_channels
}

# CR service specific # 

resource "google_monitoring_alert_policy" "service_4xx_alert_policy" {
  count = !local.is_job ? 1 : 0

  project = var.project_id

  display_name = "4xx-${local.resource_value}"
  combiner     = "OR"

  conditions {
    display_name = "${local.resource_value} bad requests high"

    condition_threshold {
      filter = <<-EOT
        metric.type="${local.metric_root_prefix}/request_count" 
        metric.label.response_code_class="4xx"
        resource.type="${local.resource_type}"
        resource.label.${local.resource_label}="${local.resource_value}"
      EOT

      duration                = "${var.service_4xx_configuration.window}s"
      comparison              = "COMPARISON_GT"
      threshold_value         = var.service_4xx_configuration.threshold
      evaluation_missing_data = "EVALUATION_MISSING_DATA_INACTIVE"

      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_DELTA"
        cross_series_reducer = "REDUCE_SUM"
        group_by_fields      = local.default_group_by_fields
      }

      trigger {
        count = var.service_4xx_configuration.consecutive_window_violations
      }
    }
  }

  alert_strategy {
    auto_close = "${local.day}s"

    notification_channel_strategy {
      renotify_interval = "${local.day}s"
    }
  }

  documentation {
    content   = var.runbook_urls.bad_request
    mime_type = "text/markdown"
  }

  notification_channels = var.notification_channels
}

resource "google_monitoring_alert_policy" "service_5xx_alert_policy" {
  count = !local.is_job ? 1 : 0

  project = var.project_id

  display_name = "5xx-${local.resource_value}"
  combiner     = "OR"

  conditions {
    display_name = "${local.resource_value} faults high"

    condition_threshold {
      filter = <<-EOT
        metric.type="${local.metric_root_prefix}/request_count" 
        metric.label.response_code_class="5xx"
        resource.type="${local.resource_type}"
        resource.label.${local.resource_label}="${local.resource_value}"
      EOT

      duration                = "${var.service_5xx_configuration.window}s"
      comparison              = "COMPARISON_GT"
      threshold_value         = var.service_5xx_configuration.threshold
      evaluation_missing_data = "EVALUATION_MISSING_DATA_INACTIVE"

      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_DELTA"
        cross_series_reducer = "REDUCE_SUM"
        group_by_fields      = local.default_group_by_fields
      }

      trigger {
        count = var.service_5xx_configuration.consecutive_window_violations
      }
    }
  }

  alert_strategy {
    auto_close = "${local.day}s"

    notification_channel_strategy {
      renotify_interval = "${local.day}s"
    }
  }

  documentation {
    content   = var.runbook_urls.server_fault
    mime_type = "text/markdown"
  }

  notification_channels = var.notification_channels
}

resource "google_monitoring_alert_policy" "service_latency_alert_policy" {
  count = !local.is_job ? 1 : 0

  project = var.project_id

  display_name = "Latency-${local.resource_value}"
  combiner     = "OR"

  conditions {
    display_name = "${local.resource_value} P${var.service_latency_configuration.p_value} request latency high"

    condition_threshold {
      filter = <<-EOT
        metric.type="${local.metric_root_prefix}/request_latencies" 
        resource.type="${local.resource_type}"
        resource.label.${local.resource_label}="${local.resource_value}"
      EOT

      duration        = "${var.service_latency_configuration.window}s"
      comparison      = "COMPARISON_GT"
      threshold_value = var.service_latency_configuration.threshold

      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_PERCENTILE_${var.service_latency_configuration.p_value}"
        cross_series_reducer = "REDUCE_PERCENTILE_${var.service_latency_configuration.p_value}"
        group_by_fields      = local.default_group_by_fields
      }

      trigger {
        count = var.service_latency_configuration.consecutive_window_violations
      }
    }
  }

  alert_strategy {
    auto_close = "${local.day}s"

    notification_channel_strategy {
      renotify_interval = "${local.day}s"
    }
  }

  documentation {
    content   = var.runbook_urls.request_latency
    mime_type = "text/markdown"
  }

  notification_channels = var.notification_channels
}

resource "google_monitoring_alert_policy" "service_max_conns_alert_policy" {
  count = !local.is_job ? 1 : 0

  project = var.project_id

  display_name = "Max-Connections-${local.resource_value}"
  combiner     = "OR"

  conditions {
    display_name = "${local.resource_value} P${var.service_max_conns_configuration.p_value} max connections high"

    condition_threshold {
      filter = <<-EOT
        metric.type="${local.metric_root_prefix}/container/max_request_concurrencies" 
        resource.type="${local.resource_type}"
        resource.label.${local.resource_label}="${local.resource_value}"
      EOT

      duration        = "${var.service_max_conns_configuration.window}s"
      comparison      = "COMPARISON_GT"
      threshold_value = var.service_max_conns_configuration.threshold

      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_PERCENTILE_${var.service_max_conns_configuration.p_value}"
        cross_series_reducer = "REDUCE_PERCENTILE_${var.service_max_conns_configuration.p_value}"
        group_by_fields      = local.default_group_by_fields
      }

      trigger {
        count = var.service_max_conns_configuration.consecutive_window_violations
      }
    }
  }

  alert_strategy {
    auto_close = "${local.day}s"

    notification_channel_strategy {
      renotify_interval = "${local.day}s"
    }
  }

  documentation {
    content   = var.runbook_urls.container_util
    mime_type = "text/markdown"
  }

  notification_channels = var.notification_channels
}

# CR job specific #

resource "google_monitoring_alert_policy" "job_failure_alert_policy" {
  count = local.is_job ? 1 : 0

  project = var.project_id

  display_name = "FailedJobExecution-${local.resource_value}"
  combiner     = "OR"

  conditions {
    display_name = "${local.resource_value} failure count"

    condition_threshold {
      filter = <<-EOT
        metric.type="${local.metric_root_prefix}/completed_execution_count" 
        metric.label.result="failed"
        resource.type="${local.resource_type}"
        resource.label.${local.resource_label}="${local.resource_value}"
      EOT

      duration                = "${var.job_failure_configuration.window}s"
      comparison              = "COMPARISON_GT"
      threshold_value         = var.job_failure_configuration.threshold
      evaluation_missing_data = "EVALUATION_MISSING_DATA_INACTIVE"

      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_DELTA"
        cross_series_reducer = "REDUCE_SUM"
        group_by_fields      = local.default_group_by_fields
      }

      trigger {
        count = var.job_failure_configuration.consecutive_window_violations
      }
    }
  }

  alert_strategy {
    auto_close = "${local.day}s"

    notification_channel_strategy {
      renotify_interval = "${local.day}s"
    }
  }

  notification_channels = var.notification_channels
}
