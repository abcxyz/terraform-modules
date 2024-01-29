module "github_cicd_workflow_vars" {
  source = "git::https://github.com/abcxyz/terraform-modules/modules/github_cicd_workflow_vars?ref=SHA_OR_TAG_HERE"

  infra_project_id             = "my-project-id"
  github_repository_name       = "repository-name"
  wif_provider_name            = "projects/111111111111/locations/global/workloadIdentityPools/pool-id/providers/provider-id"
  service_account_email        = "service-account@my-project-id.iam.gserviceaccount.com"
  artifact_repository_id       = "artifact-registry-id"
  artifact_repository_location = "US"
  environment_projects = {
    "development" = "my-development-project-id"
    "production"  = "my-production-project-id"
  }
}
