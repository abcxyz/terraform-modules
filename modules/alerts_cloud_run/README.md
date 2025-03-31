<!-- BEGIN_TF_DOCS -->
## Examples

```terraform
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
      log_name_suffix    = "stdout"
      severity           = "ERROR"
      additional_filters = "jsonPayload.message=\"foo\" AND jsonPayload.method=<your_method_name>"

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
    enabled      = true
    window       = 300
    threshold_ms = 0
    p_value      = 95
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
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_advanced_json_alert_policies"></a> [advanced\_json\_alert\_policies](#input\_advanced\_json\_alert\_policies) | Map of alert policies that can combine multiple advanced metrics. | <pre>map(object({<br/>    display_name = string<br/>    severity     = optional(string, "ERROR")<br/>    # List of metrics to include in this policy (optional if filter is provided)<br/>    metrics = optional(list(string), [])<br/>    # Custom filter (overrides automatic metric list creation)<br/>    filter = optional(string)<br/>    # Optional custom settings for all metrics in this policy<br/>    condition_settings = optional(object({<br/>      duration        = optional(string, "60s")<br/>      threshold       = optional(number, 1)<br/>      aligner         = optional(string, "ALIGN_RATE")<br/>      reducer         = optional(string, "REDUCE_SUM")<br/>      group_by_fields = optional(list(string))<br/>    }))<br/>    # Runbook URL for this policy<br/>    runbook_url = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_advanced_log_based_json_indicators"></a> [advanced\_log\_based\_json\_indicators](#input\_advanced\_log\_based\_json\_indicators) | Map for advanced log based indicators using JSON payload with custom label extractors and metric descriptors. | <pre>map(object({<br/>    name             = string<br/>    description      = optional(string)<br/>    filter           = string<br/>    label_extractors = map(string)<br/>    metric_kind      = string<br/>    value_type       = string<br/>    labels = list(object({<br/>      key         = string<br/>      value_type  = string<br/>      description = string<br/>    }))<br/>    # Alert condition for this specific metric<br/>    alert_condition = optional(object({<br/>      duration        = string<br/>      threshold       = number<br/>      aligner         = string<br/>      reducer         = string<br/>      filter          = optional(string)<br/>      group_by_fields = optional(list(string))<br/>      policy_name     = optional(string)<br/>      policy_severity = optional(string, "ERROR")<br/>      runbook_url     = optional(string)<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_built_in_container_util_indicators"></a> [built\_in\_container\_util\_indicators](#input\_built\_in\_container\_util\_indicators) | Map for Cloud Run container utilization indicators. The window must be in seconds. Threshold should be represented | <pre>map(object({<br/>    metric                     = string<br/>    window                     = number<br/>    threshold                  = number<br/>    p_value                    = optional(number)<br/>    additional_filters         = optional(string)<br/>    additional_group_by_fields = optional(list(string))<br/>  }))</pre> | `{}` | no |
| <a name="input_built_in_forward_progress_indicators"></a> [built\_in\_forward\_progress\_indicators](#input\_built\_in\_forward\_progress\_indicators) | Map for forward progress Cloud Run indicators. The window must be in seconds. | <pre>map(object({<br/>    metric                     = string<br/>    window                     = number<br/>    threshold                  = number<br/>    additional_filters         = optional(string)<br/>    additional_group_by_fields = optional(list(string))<br/>  }))</pre> | `{}` | no |
| <a name="input_cloud_run_resource"></a> [cloud\_run\_resource](#input\_cloud\_run\_resource) | One of either service name or job name which will dictate the Cloud Run resource to monitor. | <pre>object({<br/>    service_name = optional(string)<br/>    job_name     = optional(string)<br/>  })</pre> | n/a | yes |
| <a name="input_enable_advanced_log_based_json_indicators"></a> [enable\_advanced\_log\_based\_json\_indicators](#input\_enable\_advanced\_log\_based\_json\_indicators) | A flag to enable or disable the creation of advanced log based JSON indicators. | `bool` | `false` | no |
| <a name="input_enable_built_in_container_indicators"></a> [enable\_built\_in\_container\_indicators](#input\_enable\_built\_in\_container\_indicators) | A flag to enable or disable the creation of built in container utilization indicators. | `bool` | `false` | no |
| <a name="input_enable_built_in_forward_progress_indicators"></a> [enable\_built\_in\_forward\_progress\_indicators](#input\_enable\_built\_in\_forward\_progress\_indicators) | A flag to enable or disable the creation of built in forward progress indicators. | `bool` | `false` | no |
| <a name="input_enable_log_based_json_indicators"></a> [enable\_log\_based\_json\_indicators](#input\_enable\_log\_based\_json\_indicators) | A flag to enable or disable the creation of log based JSON indicators. | `bool` | `false` | no |
| <a name="input_enable_log_based_text_indicators"></a> [enable\_log\_based\_text\_indicators](#input\_enable\_log\_based\_text\_indicators) | A flag to enable or disable the creation of log based text indicators. | `bool` | `false` | no |
| <a name="input_job_failure_configuration"></a> [job\_failure\_configuration](#input\_job\_failure\_configuration) | Configuration applied to the job failure alert policy. Only applies to jobs. | <pre>object({<br/>    enabled                    = bool<br/>    window                     = number<br/>    threshold                  = number<br/>    additional_filters         = optional(string)<br/>    additional_group_by_fields = optional(list(string))<br/>  })</pre> | <pre>{<br/>  "additional_filters": "",<br/>  "additional_group_by_fields": [],<br/>  "enabled": false,<br/>  "threshold": 0,<br/>  "window": 300<br/>}</pre> | no |
| <a name="input_log_based_json_indicators"></a> [log\_based\_json\_indicators](#input\_log\_based\_json\_indicators) | Map for log based indicators using JSON payload. Payload message is a regex match. | <pre>map(object({<br/>    log_name_suffix = string<br/>    severity        = string<br/>    condition_threshold = object({<br/>      window    = number<br/>      threshold = number<br/>    })<br/>    additional_filters         = optional(string)<br/>    additional_group_by_fields = optional(list(string))<br/>  }))</pre> | `{}` | no |
| <a name="input_log_based_text_indicators"></a> [log\_based\_text\_indicators](#input\_log\_based\_text\_indicators) | Map for log based indicators using text payload. Payload message is a regex match. | <pre>map(object({<br/>    log_name_suffix      = string<br/>    severity             = string<br/>    text_payload_message = string<br/>    condition_threshold = object({<br/>      window    = number<br/>      threshold = number<br/>    })<br/>    additional_filters         = optional(string)<br/>    additional_group_by_fields = optional(list(string))<br/>  }))</pre> | `{}` | no |
| <a name="input_notification_channels_non_paging"></a> [notification\_channels\_non\_paging](#input\_notification\_channels\_non\_paging) | List of notification channels to alert. | `list(string)` | `[]` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The GCP project ID. | `string` | n/a | yes |
| <a name="input_runbook_urls"></a> [runbook\_urls](#input\_runbook\_urls) | URLs of markdown files. | <pre>object({<br/>    forward_progress = optional(string)<br/>    container_util   = optional(string)<br/>    bad_request      = optional(string)<br/>    server_fault     = optional(string)<br/>    request_latency  = optional(string)<br/>    max_conns        = optional(string)<br/>    job_failure      = optional(string)<br/>    text_based_logs  = optional(string)<br/>    json_based_logs  = optional(string)<br/>  })</pre> | n/a | yes |
| <a name="input_service_4xx_configuration"></a> [service\_4xx\_configuration](#input\_service\_4xx\_configuration) | Configuration applied to the 4xx alert policy. Only applies to services. | <pre>object({<br/>    enabled                    = bool<br/>    window                     = number<br/>    threshold                  = number<br/>    additional_filters         = optional(string)<br/>    additional_group_by_fields = optional(list(string))<br/>  })</pre> | <pre>{<br/>  "additional_filters": "",<br/>  "additional_group_by_fields": [],<br/>  "enabled": false,<br/>  "threshold": 0,<br/>  "window": 300<br/>}</pre> | no |
| <a name="input_service_5xx_configuration"></a> [service\_5xx\_configuration](#input\_service\_5xx\_configuration) | Configuration applied to the 5xx alert policy. Only applies to services. | <pre>object({<br/>    enabled                    = bool<br/>    window                     = number<br/>    threshold                  = number<br/>    additional_filters         = optional(string)<br/>    additional_group_by_fields = optional(list(string))<br/>  })</pre> | <pre>{<br/>  "additional_filters": "",<br/>  "additional_group_by_fields": [],<br/>  "enabled": false,<br/>  "threshold": 0,<br/>  "window": 300<br/>}</pre> | no |
| <a name="input_service_latency_configuration"></a> [service\_latency\_configuration](#input\_service\_latency\_configuration) | Configuration applied to the request latency alert policy. Only applies to services. | <pre>object({<br/>    enabled                    = bool<br/>    window                     = number<br/>    threshold_ms               = number<br/>    p_value                    = number<br/>    additional_filters         = optional(string)<br/>    additional_group_by_fields = optional(list(string))<br/>  })</pre> | <pre>{<br/>  "additional_filters": "",<br/>  "additional_group_by_fields": [],<br/>  "enabled": false,<br/>  "p_value": 95,<br/>  "threshold_ms": 0,<br/>  "window": 300<br/>}</pre> | no |
| <a name="input_service_max_conns_configuration"></a> [service\_max\_conns\_configuration](#input\_service\_max\_conns\_configuration) | Configuration applied to the max connections alert policy. Only applies to services. | <pre>object({<br/>    enabled                    = bool<br/>    window                     = number<br/>    threshold                  = number<br/>    p_value                    = number<br/>    additional_filters         = optional(string)<br/>    additional_group_by_fields = optional(list(string))<br/>  })</pre> | <pre>{<br/>  "additional_filters": "",<br/>  "additional_group_by_fields": [],<br/>  "enabled": false,<br/>  "p_value": 95,<br/>  "threshold": 0,<br/>  "window": 300<br/>}</pre> | no |

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
| [google_logging_metric.advanced_json_payload_logging_metric](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_metric) | resource |
| [google_logging_metric.json_payload_logging_metric](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_metric) | resource |
| [google_logging_metric.text_payload_logging_metric](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_metric) | resource |
| [google_monitoring_alert_policy.combined_alert_policies](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/monitoring_alert_policy) | resource |
| [google_monitoring_alert_policy.container_util_alert_policy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/monitoring_alert_policy) | resource |
| [google_monitoring_alert_policy.forward_progress_alert_policy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/monitoring_alert_policy) | resource |
| [google_monitoring_alert_policy.individual_metric_alert_policies](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/monitoring_alert_policy) | resource |
| [google_monitoring_alert_policy.job_failure_alert_policy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/monitoring_alert_policy) | resource |
| [google_monitoring_alert_policy.json_payload_logging_alert_policy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/monitoring_alert_policy) | resource |
| [google_monitoring_alert_policy.service_4xx_alert_policy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/monitoring_alert_policy) | resource |
| [google_monitoring_alert_policy.service_5xx_alert_policy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/monitoring_alert_policy) | resource |
| [google_monitoring_alert_policy.service_latency_alert_policy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/monitoring_alert_policy) | resource |
| [google_monitoring_alert_policy.service_max_conns_alert_policy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/monitoring_alert_policy) | resource |
| [google_monitoring_alert_policy.text_payload_logging_alert_policy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/monitoring_alert_policy) | resource |
| [google_project_service.services](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |

## Modules

No modules.
<!-- END_TF_DOCS -->
