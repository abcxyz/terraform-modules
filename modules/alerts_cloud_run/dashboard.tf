resource "google_monitoring_dashboard" "default" {
  for_each = toset(var.dashboard_json_files)

  project = var.project_id

  dashboard_json = file(each.value)
}
