module "github_ci_infra" {
  source = "git::https://github.com/abcxyz/terraform-modules.git//modules/github_ci_infra?ref=SHA_OR_TAG_HERE"

  project_id = "my-project-id"

  github_owner_id        = 99999999999
  github_repository_id   = 111111111
  name                   = "name"
  registry_repository_id = "artifact-registry-id"
  registry_location      = "US"
}
