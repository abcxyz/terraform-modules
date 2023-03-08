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
  service_and_env     = "${var.service_name}-admin"
  project_name_and_id = "${substr(local.service_and_env, 0, 25)}-${random_id.default.hex}" # 30 character limit
}

resource "random_id" "default" {
  byte_length = 2
}

resource "google_project" "admin_project" {
  project_id = local.project_name_and_id
  name       = local.project_name_and_id

  folder_id       = var.folder_id
  billing_account = var.billing_account

  lifecycle {
    # We expect billing_account association to be done by a human after project creation in the common case.
    ignore_changes = [billing_account]
  }
}

resource "google_project_service" "admin_enabled_services" {
  for_each = toset([
    "iam.googleapis.com",
    "compute.googleapis.com",
  ])

  project = google_project.admin_project.project_id
  service = each.value
}

