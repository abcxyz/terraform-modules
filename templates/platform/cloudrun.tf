locals {
  # Services that are enabled on all the GCP projects (except for the admin project)
  services = [
    "iam.googleapis.com",
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
  ]
}

resource "google_project_services" "default" {
  for_each = toset(local.environments)

  project = module.{{replace .project_id "-" "_" -1}}.environments[each.key].project_id
  services = local.services

  disable_on_destroy         = false
  disable_dependent_services = false
}