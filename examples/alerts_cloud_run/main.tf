module "cloud_run_service_alerts" {
  source = "git::https://github.com/abcxyz/terraform-modules.git//modules/alerts/cloud_run?ref=SHA_OR_TAG"

  project_id = var.project_id

  cloud_run_resource = {
    service_name = "my-service-name"
  }

  notification_channels = ["notification-channel-id"]
  runbook_urls = {
    forward_progress = "https://github.com/org/repo/blob/main/docs/playbooks/alerts/ForwardProgressFailed.md"
    container_util   = "https://github.com/org/repo/blob/main/docs/playbooks/alerts/ContainerUtilization.md"
  }

  built_in_forward_progress_indicators = {
    "request-count" = {
      metric                        = "request_count"
      window                        = 2 * local.hour + 10 * local.minute
      threshold                     = 1
      consecutive_window_violations = 1
    },
  }

  built_in_container_util_indicators = {
    "cpu" = {
      metric                        = "container/cpu/utilizations"
      window                        = 10 * local.minute
      threshold                     = 0.8
      p_value                       = 99
      consecutive_window_violations = 1
    },
    "memory" = {
      metric                        = "container/memory/utilizations"
      window                        = 10 * local.minute
      threshold                     = 0.8
      p_value                       = 99
      consecutive_window_violations = 1
    },
  }

  log_based_text_indicators = {
    "scaling-failure" = {
      log_name_suffix      = "request"
      severity             = "ERROR"
      text_payload_message = "The request was aborted because there was no available instance."
      runbook_url          = "https://github.com/org/repo/blob/main/docs/playbooks/alerts/runbook.md"
      condition_threshold = {
        window                        = 10 * local.minute
        threshold                     = 1
        consecutive_window_violations = 1
      }
    }
  }

  log_based_json_indicators = {
    "email-bounce-failure" = {
      log_name_suffix      = "stdout"
      severity             = "ERROR"
      json_payload_message = "Failed.*"
      runbook_url          = "https://github.com/org/repo/blob/main/docs/playbooks/alerts/runbook.md"
      additional_filters   = "jsonPayload.method=<your_method_name>"
    }
  }

  service_4xx_configuration = {
    window                        = 300
    threshold                     = 0
    consecutive_window_violations = 1
  }

  service_5xx_configuration = {
    window                        = 300
    threshold                     = 0
    consecutive_window_violations = 1
  }

  service_latency_configuration = {
    window                        = 300
    threshold                     = 0
    consecutive_window_violations = 1
    p_value                       = 95
  }

  service_max_conns_configuration = {
    window                        = 300
    threshold                     = 0
    consecutive_window_violations = 1
    p_value                       = 95
  }

  job_failure_configuration = {
    window                        = 300
    threshold                     = 0
    consecutive_window_violations = 1
  }
}
