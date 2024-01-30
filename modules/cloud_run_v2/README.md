# abcxyz Cloud Run Module

This module provides the default Cloud Run service for abcxyz projects. It uses the terraform module `google_cloud_run_v2_service` and provides support for direct VPC. 

## Example

```terraform
resource "google_service_account" "run_service_account" {
  project      = "my-project-id"
  account_id   = "project-name-sa"
  display_name = "project-name-sa Cloud Run Service Account"
}

module "cloud_run" {
  source                    = "git::https://github.com/abcxyz/terraform-modules.git//modules/cloud_run_v2?ref=SHA_OR_TAG"
  project_id                = "my-project-id"
  name                      = "project-name"
  secrets                   = ["app-secret", "app-file-secret"]
  service_account_email     = google_service_account.run_service_account.email
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

  vpc = {
    network_id: "default",
    subnet_id: "default",
    egress: "PRIVATE_RANGES_ONLY"
  }

  invokers = ["user:test-account-group@google.com"]
  developers = [module.github_ci.service_account_email]
  
  # Connecting cloud sql -- public ip version, not recommended due to scaling issues
  # max_instances needs to be set low enough to avoid scaling issues
  # revision_annotations = {
  #   "run.googleapis.com/cloudsql-instances" = google_sql_database_instance.mysql_instance.connection_name
  # }
}
```
