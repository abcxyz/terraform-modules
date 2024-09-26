module "cloud_run_service_alerts" {
  source = "git::https://github.com/abcxyz/terraform-modules.git//modules/alerts/cloud_run?ref=SHA_OR_TAG"

  project_id = var.project_id

  cloud_run_resource = {
    service_name = "my-service-name"
  }

  notification_channels_non_paging = ["notification-channel-id"]
  runbook_urls = {
    forward_progress = "https://github.com/org/repo/blob/main/docs/playbooks/alerts/ForwardProgressFailed.md"
    container_util   = "https://github.com/org/repo/blob/main/docs/playbooks/alerts/ContainerUtilization.md"
  }

  enable_built_in_forward_progress_indicators = true
  built_in_forward_progress_indicators = {
    "request-count" = {
      metric    = "request_count"
      window    = 2 * local.hour + 10 * local.minute
      threshold = 1
    },
  }

  enable_built_in_container_indicators = true
  built_in_container_util_indicators = {
    "cpu" = {
      metric    = "container/cpu/utilizations"
      window    = 10 * local.minute
      threshold = 0.8
      p_value   = 99
    },
    "memory" = {
      metric    = "container/memory/utilizations"
      window    = 10 * local.minute
      threshold = 0.8
      p_value   = 99
    },
  }

  enable_log_based_text_indicators = true
  log_based_text_indicators = {
    "scaling-failure" = {
      log_name_suffix      = "requests"
      severity             = "ERROR"
      text_payload_message = "The request was aborted because there was no available instance."
      condition_threshold = {
        window    = 10 * local.minute
        threshold = 1
      }
    }
  }

  enable_log_based_json_indicators = true
  log_based_json_indicators = {
    "email-bounce-failure" = {
      log_name_suffix      = "stdout"
      severity             = "ERROR"
      json_payload_message = "Failed.*"
      additional_filters   = "jsonPayload.method=<your_method_name>"
      condition_threshold = {
        window    = 10 * local.minute
        threshold = 0
      }
    }
  }

  service_4xx_configuration = {
    enabled   = true
    window    = 300
    threshold = 0
  }

  service_5xx_configuration = {
    enabled   = true
    window    = 300
    threshold = 0
  }

  service_latency_configuration = {
    enabled   = true
    window    = 300
    threshold = 0
    p_value   = 95
  }

  service_max_conns_configuration = {
    window    = 300
    threshold = 0
    p_value   = 95
  }

  job_failure_configuration = {
    enabled   = false
    window    = 300
    threshold = 0
  }
}
