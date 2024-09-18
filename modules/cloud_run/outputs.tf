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

output "service_name" {
  description = "The Cloud Run service name."
  value       = google_cloud_run_service.service.name
}

output "service_id" {
  description = "The Cloud Run service id."
  value       = google_cloud_run_service.service.id
}

output "url" {
  description = "The Cloud Run service url."
  value       = google_cloud_run_service.service.status.0.url
}

output "latest_ready_revision_name" {
  description = "The Cloud Run latest revision name."
  value       = google_cloud_run_service.service.latest_ready_revision_name
}
