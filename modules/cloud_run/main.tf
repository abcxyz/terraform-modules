# Copyright 2023 The Authors (see AUTHORS file)
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
  run_service_name = "${substr(var.name, 0, 58)}-${random_id.default.hex}" # 63 character limit

  default_run_revision_annotations = {
    "autoscaling.knative.dev/minScale" : var.min_instances,
    "autoscaling.knative.dev/maxScale" : var.max_instances,
    "run.googleapis.com/sandbox" : "gvisor",
    "run.googleapis.com/execution-environment" : var.execution_environment
  }

  default_run_service_annotations = {
    "run.googleapis.com/ingress" : var.ingress
  }

  run_envvars = merge(
    {}, # defaults, currently none
    var.envvars
  )
  run_secret_envvars = merge(
    {}, # defaults, currently none
    var.secret_envvars,
  )
  run_secret_volumes = merge(
    {}, # defaults, currently none
    var.secret_volumes,
  )
}

resource "random_id" "default" {
  byte_length = 2
}

resource "google_project_service" "services" {
  for_each = toset([
    "cloudresourcemanager.googleapis.com",
    "monitoring.googleapis.com",
    "run.googleapis.com",
    "secretmanager.googleapis.com",
    "serviceusage.googleapis.com",
    "stackdriver.googleapis.com",
  ])

  project                    = var.project_id
  service                    = each.value
  disable_on_destroy         = false
  disable_dependent_services = false
}

resource "google_cloud_run_service" "service" {
  name                       = local.run_service_name
  location                   = var.region
  project                    = var.project_id
  autogenerate_revision_name = true

  metadata {
    annotations = local.default_run_service_annotations
  }

  template {
    spec {
      service_account_name = var.service_account_email
      containers {
        image = var.image

        resources {
          requests = var.resources.requests
          limits   = var.resources.limits
        }

        dynamic "env" {
          for_each = local.run_envvars

          content {
            name  = env.key
            value = env.value
          }
        }

        dynamic "env" {
          for_each = local.run_secret_envvars

          content {
            name = env.key
            value_from {
              secret_key_ref {
                key  = env.value.version
                name = env.value.name
              }
            }
          }
        }

        dynamic "volume_mounts" {
          for_each = local.run_secret_volumes
          content {
            mount_path = volume_mounts.key
            name       = volume_mounts.value.name
          }
        }
      }

      dynamic "volumes" {
        for_each = local.run_secret_volumes
        content {
          name = volumes.value.name
          secret {
            secret_name = volumes.value.name
            items {
              key  = volumes.value.version
              path = volumes.value.name
            }
          }
        }
      }
    }

    metadata {
      annotations = local.default_run_revision_annotations
    }
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations["client.knative.dev/user-image"],
      metadata[0].annotations["run.googleapis.com/client-name"],
      metadata[0].annotations["run.googleapis.com/client-version"],
      metadata[0].annotations["run.googleapis.com/ingress-status"],
      metadata[0].annotations["run.googleapis.com/launch-stage"],
      metadata[0].annotations["run.googleapis.com/operation-id"],
      metadata[0].annotations["serving.knative.dev/creator"],
      metadata[0].annotations["serving.knative.dev/lastModifier"],
      metadata[0].labels["cloud.googleapis.com/location"],
      template[0].metadata[0].annotations["client.knative.dev/user-image"],
      template[0].metadata[0].annotations["run.googleapis.com/client-name"],
      template[0].metadata[0].annotations["run.googleapis.com/client-version"],
      template[0].metadata[0].annotations["run.googleapis.com/sandbox"],
      template[0].metadata[0].annotations["serving.knative.dev/creator"],
      template[0].metadata[0].annotations["serving.knative.dev/lastModifier"],
      template[0].spec[0].containers[0].image,
    ]
  }

  depends_on = [
    google_project_service.services["run.googleapis.com"],
    google_secret_manager_secret_iam_member.secrets_accessors_iam,
  ]
}

resource "google_cloud_run_service_iam_binding" "admins" {
  location = google_cloud_run_service.service.location
  project  = google_cloud_run_service.service.project
  service  = google_cloud_run_service.service.name
  role     = "role/run.admin"
  members  = toset(var.service_iam.admins)
}

resource "google_cloud_run_service_iam_binding" "invokers" {
  location = google_cloud_run_service.service.location
  project  = google_cloud_run_service.service.project
  service  = google_cloud_run_service.service.name
  role     = "role/run.invoker"
  members  = toset(var.service_iam.invokers)
}

resource "google_cloud_run_service_iam_binding" "developers" {
  location = google_cloud_run_service.service.location
  project  = google_cloud_run_service.service.project
  service  = google_cloud_run_service.service.name
  role     = "role/run.developer"
  members  = toset(var.service_iam.developers)
}

resource "google_project_iam_member" "run_observability_iam" {
  for_each = toset([
    "roles/cloudtrace.agent",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/stackdriver.resourceMetadata.writer",
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${var.service_account_email}"

  depends_on = [
    google_project_service.services["iam.googleapis.com"],
  ]
}

# Secret Manager secrets for the Cloud Run service to use
resource "google_secret_manager_secret" "secrets" {
  for_each = toset(var.secrets)

  project   = var.project_id
  secret_id = each.value
  replication {
    automatic = true
  }

  depends_on = [
    google_project_service.services["secretmanager.googleapis.com"]
  ]
}

resource "google_secret_manager_secret_version" "secrets_default_version" {
  for_each = toset(var.secrets)

  secret = google_secret_manager_secret.secrets[each.key].id
  # default value used for initial revision to allow cloud run to map the secret
  # to manage this value and versions, use the google cloud web application
  secret_data = "DEFAULT_VALUE"
}

resource "google_secret_manager_secret_iam_member" "secrets_accessors_iam" {
  for_each = toset(var.secrets)

  project   = var.project_id
  secret_id = google_secret_manager_secret.secrets[each.key].id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${var.service_account_email}"
}
