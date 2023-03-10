# abcxyz Cloud Run Module

This module provides the default Cloud Run service for abcxyz projects.

## Example

```terraform
resource "google_service_account" "run_service_account" {
  project      = "my-project-id"
  account_id   = "project-name-sa"
  display_name = "project-name-sa Cloud Run Service Account"
}

module "cloud_run" {
  source                    = "https://github.com/abcxyz/infra/terraform/modules/cloud_run"
  project_id                = "my-project-id"
  name                      = "project-name"
  secrets                   = ["app-secret", "app-file-secret"]
  service_account_email = google_service_account.run_service_account.email
  envvars = {
    "PROJECT_ID" : "my-project-id",
  }

  secret_envvars = {
    "APP_SECRET" : {
      name : "app-secret",
      version : "latest",
    }
  }

  secret_volumes = {
    "/var/secrets" : {
      name : "app-file-secret",
      version : "latest",
    }
  }

  invokers = ["user:test-account-group@google.com"]
  developers = [module.github_ci.service_account_email]
}
```
