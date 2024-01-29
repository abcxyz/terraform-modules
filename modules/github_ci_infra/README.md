<!-- BEGIN_TF_DOCS -->
## Examples

```terraform
module "github_ci_infra" {
  source = "git::https://github.com/abcxyz/terraform-modules.git//modules/github_ci_infra?ref=SHA_OR_TAG_HERE"

  project_id = "my-project-id"

  github_owner_id        = 99999999999
  github_repository_id   = 111111111
  name                   = "name"
  registry_repository_id = "artifact-registry-id"
  registry_location      = "US"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_github_owner_id"></a> [github\_owner\_id](#input\_github\_owner\_id) | The GitHub ID of the owner of the repository whose workflows will be granted access to the WIF pool (i.e. an organization ID or user ID). | `number` | n/a | yes |
| <a name="input_github_repository_id"></a> [github\_repository\_id](#input\_github\_repository\_id) | The GitHub ID of the repository whose workflows will be granted access to the WIF pool. | `number` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of this project. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The Google Cloud project ID. | `string` | n/a | yes |
| <a name="input_registry_location"></a> [registry\_location](#input\_registry\_location) | The location to create the artifact registry repository (defaults to 'us'). | `string` | `"us"` | no |
| <a name="input_registry_repository_id"></a> [registry\_repository\_id](#input\_registry\_repository\_id) | The id of the artifact registry repository to be created (defaults to 'ci-images'). | `string` | `"ci-images"` | no |
| <a name="input_wif_pool_name"></a> [wif\_pool\_name](#input\_wif\_pool\_name) | The Workload Identity Federation pool name. | `string` | `"github-pool"` | no |
| <a name="input_wif_provider_name"></a> [wif\_provider\_name](#input\_wif\_provider\_name) | The Workload Identity Federation provider name. | `string` | `"github-provider"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_artifact_repository_id"></a> [artifact\_repository\_id](#output\_artifact\_repository\_id) | The Artifact Registry ID, e.g. ci-images |
| <a name="output_artifact_repository_location"></a> [artifact\_repository\_location](#output\_artifact\_repository\_location) | The Artifact Registry repository location, e.g. "us" or "us-west1" |
| <a name="output_artifact_repository_name"></a> [artifact\_repository\_name](#output\_artifact\_repository\_name) | The Artifact Registry name. |
| <a name="output_service_account_email"></a> [service\_account\_email](#output\_service\_account\_email) | CI service account identity email address. |
| <a name="output_service_account_member"></a> [service\_account\_member](#output\_service\_account\_member) | CI service account identity in the form serviceAccount:{email}. |
| <a name="output_wif_pool_name"></a> [wif\_pool\_name](#output\_wif\_pool\_name) | The Workload Identity Federation pool name. |
| <a name="output_wif_provider_name"></a> [wif\_provider\_name](#output\_wif\_provider\_name) | The Workload Identity Federation provider name. |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.45 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.45 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Resources

| Name | Type |
|------|------|
| [google_artifact_registry_repository.artifact_repository](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository) | resource |
| [google_artifact_registry_repository_iam_binding.ci_service_account_iam](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository_iam_binding) | resource |
| [google_iam_workload_identity_pool.github_pool](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool) | resource |
| [google_iam_workload_identity_pool_provider.github_provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool_provider) | resource |
| [google_project_service.services](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_service_account.ci_service_account](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_iam_member.wif_github_iam](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |
| [random_id.default](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Modules

No modules.
<!-- END_TF_DOCS -->