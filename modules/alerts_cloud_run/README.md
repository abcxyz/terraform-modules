<!-- BEGIN_TF_DOCS -->
## Examples

```terraform
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
    "scaling-failure" : {
      log_name_suffix = "request"
      severity        = "ERROR"
      textPayload     = "The request was aborted because there was no available instance."
    }
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_built_in_cpu_indicators"></a> [built\_in\_cpu\_indicators](#input\_built\_in\_cpu\_indicators) | Map for CPU Cloud Run indicators. The window must be in seconds. | <pre>map(object({<br>    metric    = string<br>    window    = number<br>    threshold = number<br>  }))</pre> | n/a | yes |
| <a name="input_built_in_forward_progress_indicators"></a> [built\_in\_forward\_progress\_indicators](#input\_built\_in\_forward\_progress\_indicators) | Map for forward progress Cloud Run indicators. The window must be in seconds. | <pre>map(object({<br>    metric = string<br>    window = number<br>  }))</pre> | n/a | yes |
| <a name="input_cloud_run_resource"></a> [cloud\_run\_resource](#input\_cloud\_run\_resource) | One of either service name or job name which will dictate the Cloud Run resource to monitor. | <pre>object({<br>    service_name = optional(string)<br>    job_name     = optional(string)<br>  })</pre> | n/a | yes |
| <a name="input_log_based_text_indicators"></a> [log\_based\_text\_indicators](#input\_log\_based\_text\_indicators) | Map for Cloud Run log based indicators. Only support text payload logs. | <pre>map(object({<br>    log_name_suffix = string<br>    severity        = string<br>    textPayload     = string<br>  }))</pre> | n/a | yes |
| <a name="input_notification_channels"></a> [notification\_channels](#input\_notification\_channels) | List of notification channels to alert. | `list(string)` | `[]` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The GCP project ID. | `string` | n/a | yes |
| <a name="input_runbook_urls"></a> [runbook\_urls](#input\_runbook\_urls) | URLs of markdown files. | <pre>object({<br>    forward_progress = string<br>    cpu              = string<br>  })</pre> | <pre>{<br>  "cpu": "",<br>  "forward_progress": ""<br>}</pre> | no |

## Outputs

No outputs.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.83.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.83.0 |

## Resources

| Name | Type |
|------|------|
| [google_logging_metric.text_payload_logging_metric](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_metric) | resource |
| [google_monitoring_alert_policy.cpu_alert_policy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/monitoring_alert_policy) | resource |
| [google_monitoring_alert_policy.forward_progress_alert_policy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/monitoring_alert_policy) | resource |
| [google_monitoring_alert_policy.text_payload_logging_alert_policy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/monitoring_alert_policy) | resource |
| [google_project_service.services](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |

## Modules

No modules.
<!-- END_TF_DOCS -->
