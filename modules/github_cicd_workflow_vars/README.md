<!-- BEGIN_TF_DOCS -->
## Examples

```terraform
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
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_artifact_repository_id"></a> [artifact\_repository\_id](#input\_artifact\_repository\_id) | ID of the Artifact Registry repository containing docker images. E.g. 'my-image-repo' | `string` | n/a | yes |
| <a name="input_artifact_repository_location"></a> [artifact\_repository\_location](#input\_artifact\_repository\_location) | Location of the artifact registry repository. Either a region name or a multi-regional location name. E.g. 'us', 'us-west1' | `string` | n/a | yes |
| <a name="input_environment_projects"></a> [environment\_projects](#input\_environment\_projects) | A map where the keys are GitHub environment names and the values are the GCP project IDs where that environment runs. | `map(string)` | n/a | yes |
| <a name="input_github_repository_name"></a> [github\_repository\_name](#input\_github\_repository\_name) | The name of the GitHub repository containing the service's source code, not including the org/owner. E.g. 'my-service' | `string` | n/a | yes |
| <a name="input_infra_project_id"></a> [infra\_project\_id](#input\_infra\_project\_id) | The GCP project ID that contains the Artifact Registry repository. | `string` | n/a | yes |
| <a name="input_service_account_email"></a> [service\_account\_email](#input\_service\_account\_email) | CI service account identity in the form serviceAccount:{email}. | `string` | n/a | yes |
| <a name="input_wif_provider_name"></a> [wif\_provider\_name](#input\_wif\_provider\_name) | The Workload Identity Federation provider name | `string` | n/a | yes |

## Outputs

No outputs.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | ~> 5.18 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_github"></a> [github](#provider\_github) | ~> 5.18 |

## Resources

| Name | Type |
|------|------|
| [github_actions_environment_variable.project_id_for_env](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_environment_variable) | resource |
| [github_actions_variable.gar_location](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_variable) | resource |
| [github_actions_variable.gar_repo_id](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_variable) | resource |
| [github_actions_variable.infra_project_id](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_variable) | resource |
| [github_actions_variable.wif_provider](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_variable) | resource |
| [github_actions_variable.wif_service_account](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_variable) | resource |

## Modules

No modules.
<!-- END_TF_DOCS -->