module "cloud_run_service_alerts" {
  source = "git::https://github.com/abcxyz/terraform-modules.git//modules/alerts/cloud_run?ref=SHA_OR_TAG"

  project_id = var.project_id

  cloud_run_resource = {
    service_name = "my-service-name"
  }

  notification_channels = ["notification-channel-id"]
  runbook_urls = {
    forward_progress = "https://github.com/org/repo/blob/main/docs/playbooks/alerts/ForwardProgressFailed.md"
    cpu              = "https://github.com/org/repo/blob/main/docs/playbooks/alerts/IncreasedCPUUsage.md"
  }

  built_in_forward_progress_indicators = {
    "request-count" = { metric = "request_count", window = 2 * local.hour + 10 * local.minute },
  }

  built_in_cpu_indicators = {
    "cpu-utilization" = { metric = "utilization", window = 10 * local.minute, threshold : 0.8 },
  }

  log_based_text_indicators = {
    "scaling-failure" = {
      log_name_suffix = "request"
      severity        = "ERROR"
      textPayload     = "The request was aborted because there was no available instance."
    }
  }
}
