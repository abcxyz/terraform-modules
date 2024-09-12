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

  forward_progress_prefix = local.is_job ? "${local.metric_root}/job" : local.metric_root
  cpu_metric_prefix       = "${local.metric_root}/container/cpu"

  resource_type  = local.is_job ? "cloud_run_job" : "cloud_run_revision"
  resource_label = local.is_job ? "job_name" : "service_name"
  resource_value = local.is_job ? var.cloud_run_resource.job_name : var.cloud_run_resource.service_name

  second = 1
  minute = 60 * local.second
  hour   = 60 * local.minute
  day    = 24 * local.hour

}

resource "google_monitoring_alert_policy" "forward_progress_alert_policy" {
  for_each = var.built_in_forward_progress_indicators

  project = var.project_id

  display_name = "ForwardProgress-${each.key}-${local.resource_value}"
  combiner     = "OR"

  conditions {
    display_name = "${local.resource_value} ${each.key} failing"

    condition_threshold {
      filter = <<-EOT
        metric.type="${local.forward_progress_prefix}/${each.value.metric}" 
        resource.type="${local.resource_type}"
        resource.label.${local.resource_label}="${local.resource_value}"
      EOT

      duration        = "${each.value.window}s"
      comparison      = "COMPARISON_LT"
      threshold_value = 1

      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_DELTA"
        group_by_fields      = ["resource.labels.${local.resource_label}"]
        cross_series_reducer = "REDUCE_SUM"
      }

      trigger {
        count = 1
      }
    }
  }

  conditions {
    display_name = "${local.resource_value} ${each.key} missing"

    condition_absent {
      filter = <<-EOT
        metric.type="${local.forward_progress_prefix}/${each.value.metric}" 
        resource.type="${local.resource_type}" 
        resource.label.${local.resource_label}="${local.resource_value}"
      EOT

      duration = "${each.value.window}s"

      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_DELTA"
        group_by_fields      = ["resource.labels.${local.resource_label}"]
        cross_series_reducer = "REDUCE_SUM"
      }
    }
  }

  alert_strategy {
    auto_close = "${local.day}s"

    notification_channel_strategy {
      renotify_interval = "${local.day}s"
    }
  }

  dynamic "documentation" {
    for_each = var.runbook_urls.forward_progress != "" ? [1] : []
    content {
      content   = var.runbook_urls.forward_progress
      mime_type = "text/markdown"
    }
  }

  notification_channels = var.notification_channels
}

resource "google_monitoring_alert_policy" "cpu_alert_policy" {
  for_each = var.built_in_cpu_indicators

  project = var.project_id

  display_name = "CPU-${each.key}-${local.resource_value}"
  combiner     = "OR"

  conditions {
    display_name = "${local.resource_value} CPU ${each.key} above threshold"

    condition_threshold {
      filter = <<-EOT
        metric.type="${local.cpu_metric_prefix}/${each.value.metric}" 
        resource.type="${local.resource_type}" 
        resource.label.${local.resource_label}="${local.resource_value}"
      EOT

      duration        = "${each.value.window}s"
      comparison      = "COMPARISON_GT"
      threshold_value = each.value.threshold

      aggregations {
        alignment_period     = "60s"
        per_series_aligner   = "ALIGN_DELTA"
        group_by_fields      = ["resource.labels.${local.resource_label}"]
        cross_series_reducer = "REDUCE_PERCENTILE_99"
      }

      trigger {
        count = 1
      }
    }
  }

  alert_strategy {
    auto_close = "${local.day}s"

    notification_channel_strategy {
      renotify_interval = "${local.day}s"
    }
  }

  dynamic "documentation" {
    for_each = var.runbook_urls.cpu != "" ? [1] : []
    content {
      content   = var.runbook_urls.cpu
      mime_type = "text/markdown"
    }
  }

  notification_channels = var.notification_channels
}
