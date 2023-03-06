output "resources" {
  description = "The set of values that will be provided to each cloudrun_cicd_environment module; they're bundled to avoid copypasta."
  value = {
    folder_id                    = var.folder_id
    billing_account              = var.billing_account
    admin_project_id             = google_project.admin_project.project_id
    cicd_service_account_email   = module.github_ci_access_config.service_account_email
    github_repository_name       = var.github_repository_name
    service_name                 = var.service_name
    artifact_repository_location = module.github_ci_access_config.artifact_repository_location
    artifact_repository_id       = module.github_ci_access_config.artifact_repository_id
  }
}
