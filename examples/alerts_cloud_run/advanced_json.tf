module "cloud_run_monitoring" {
  source = "git::https://github.com/abcxyz/terraform-modules.git//modules/alerts/cloud_run?ref=SHA_OR_TAG"

  project_id = var.project_id

  cloud_run_resource = {
    service_name = "grpc-cloud-run-service"
  }

  # Runbook URLs for different alert types
  runbook_urls = {
    json_based_logs = "https://example.com/runbooks/general-logs"
    server_fault    = "https://example.com/runbooks/server-errors"
  }

  # notification_channels_non_paging = [
  #   "projects/my-project-id/notificationChannels/12345"
  # ]

  # Enable standard monitoring features as needed
  # enable_built_in_forward_progress_indicators = true
  # enable_built_in_container_indicators        = true

  # Enable the advanced log based JSON indicators
  enable_advanced_log_based_json_indicators = true

  # Define advanced log based JSON indicators
  advanced_log_based_json_indicators = {
    # Metric with its own individual policy
    database_errors = {
      name        = "database_error_count"
      description = "Counts database connection and query errors"
      filter      = <<EOT
          resource.type="cloud_run_revision"
          AND severity="ERROR"
          AND jsonPayload.message=~"database (connection|query) error"
        EOT
      label_extractors = {
        error_type = "REGEXP_EXTRACT(jsonPayload.message, \"database (connection|query) error\")"
      }
      metric_kind = "DELTA"
      value_type  = "INT64"
      labels = [
        {
          key         = "error_type"
          value_type  = "STRING"
          description = "Type of database error"
        }
      ]
      # This metric has its own policy
      alert_condition = {
        duration        = "60s"
        threshold       = 1
        aligner         = "ALIGN_RATE"
        reducer         = "REDUCE_SUM"
        policy_name     = "Database-Error-Alert"
        policy_severity = "ERROR"
      }
    },

    # Metric definitions without individual alert policies
    grpc_errors = {
      name        = "grpc_status_code_count"
      description = "Tracks GRPC errors by status code and method"
      filter      = <<EOT
          resource.type="cloud_run_revision"
          AND severity="ERROR"
          AND jsonPayload.message:"error"
          AND jsonPayload.grpc_status_code:*
        EOT
      label_extractors = {
        grpc_status_code = "EXTRACT(jsonPayload.grpc_status_code)"
        method           = "EXTRACT(jsonPayload.method)"
      }
      metric_kind = "DELTA"
      value_type  = "INT64"
      labels = [
        {
          key         = "grpc_status_code"
          value_type  = "STRING"
          description = "GRPC status code"
        },
        {
          key         = "method"
          value_type  = "STRING"
          description = "Method name"
        }
      ]
      # No alert_condition defined - this metric will be used in combined policies
    },

    grpc_latency = {
      name        = "grpc_latency_high"
      description = "Detects high latency in GRPC calls"
      filter      = <<EOT
          resource.type="cloud_run_revision"
          AND severity >= "WARNING"
          AND jsonPayload.message=~"grpc call exceeded .+ ms"
        EOT
      label_extractors = {
        method = "EXTRACT(jsonPayload.method)"
      }
      metric_kind = "DELTA"
      value_type  = "INT64"
      labels = [
        {
          key         = "method"
          value_type  = "STRING"
          description = "GRPC method with high latency"
        }
      ]
      # No alert_condition defined - this metric will be used in combined policies
    },

    storage_errors = {
      name        = "storage_error_count"
      description = "Counts storage operation errors"
      filter      = <<EOT
          resource.type="cloud_run_revision"
          AND severity="ERROR"
          AND jsonPayload.message=~"storage (read|write|delete) failed"
        EOT
      label_extractors = {
        operation = "REGEXP_EXTRACT(jsonPayload.message, \"storage (read|write|delete) failed\")"
      }
      metric_kind = "DELTA"
      value_type  = "INT64"
      labels = [
        {
          key         = "operation"
          value_type  = "STRING"
          description = "Storage operation that failed"
        }
      ]
      # No alert_condition defined - this metric will be used in combined policies
    }
  }

  # Define combined alert policies
  advanced_json_alert_policies = {
    api_issues = {
      display_name = "API-Issues-Alert"
      severity     = "WARNING"
      metrics      = ["grpc_errors", "grpc_latency"]
      condition_settings = {
        duration        = "300s"
        threshold       = 5
        aligner         = "ALIGN_RATE"
        reducer         = "REDUCE_SUM"
        group_by_fields = ["resource.label.location"]
      }
      runbook_url = "https://example.com/runbooks/api-issues"
    },

    storage_and_db = {
      display_name = "Storage-and-Database-Issues"
      severity     = "ERROR"
      metrics      = ["storage_errors", "database_errors"]
      condition_settings = {
        duration  = "60s"
        threshold = 1
        aligner   = "ALIGN_RATE"
        reducer   = "REDUCE_SUM"
      }
    }
  }
}
