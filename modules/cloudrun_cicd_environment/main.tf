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
  service_and_env     = "${var.svc.service_name}-${var.environment_name}"
  project_name_and_id = "${substr(local.service_and_env, 0, 25)}-${random_id.default.hex}" # 30 character limit
}

resource "random_id" "default" {
  byte_length = 2
}

resource "google_project" "project" {
  name       = local.project_name_and_id
  project_id = local.project_name_and_id

  folder_id       = var.svc.folder_id
  billing_account = var.svc.billing_account

  lifecycle {
    # We expect billing_account association to be done by a human after project creation in the common case.
    ignore_changes = [billing_account]
  }
}

resource "google_project_service" "default" {
  for_each = toset([
    "iam.googleapis.com",
    "run.googleapis.com",
  ])

  project = google_project.project.project_id
  service = each.value
}

resource "google_service_account" "cloudrun_service_account" {
  project    = google_project.project.project_id
  account_id = "cloudrun-sa"

  depends_on = [google_project_service.default]
}

resource "google_service_account_iam_member" "impersonate" {
  service_account_id = google_service_account.cloudrun_service_account.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${var.svc.cicd_service_account_email}"
}

module "cloud_run_service" {
  source = "../cloud_run"

  project_id            = google_project.project.project_id
  region                = var.cloudrun_region
  name                  = var.svc.service_name
  min_instances         = var.min_cloudrun_instances
  ingress               = var.cloudrun_ingress
  image                 = var.initial_container_image
  service_account_email = google_service_account.cloudrun_service_account.email
  service_iam = {
    developers = ["serviceAccount:${var.svc.cicd_service_account_email}"]
    admins     = []
    invokers   = var.cloudrun_invokers
  }
}

# The Cloud Run Service Agent must have read access to the GAR repo. 
resource "google_artifact_registry_repository_iam_member" "cloudrun_sa_gar_reader" {
  project    = var.svc.admin_project_id
  location   = var.svc.artifact_repository_location
  repository = var.svc.artifact_repository_id
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:service-${google_project.project.number}@serverless-robot-prod.iam.gserviceaccount.com"
  depends_on = [
    module.cloud_run_service
  ]
}
