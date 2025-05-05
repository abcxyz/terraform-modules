<!-- BEGIN_TF_DOCS -->
## Examples

```terraform
resource "google_service_account" "run_service_account" {
  project = "my-project-id"

  account_id   = "project-name-sa"
  display_name = "project-name-sa Cloud Run Service Account"
}

module "cloud_run" {
  source = "git::https://github.com/abcxyz/terraform-modules.git//modules/cloud_run?ref=SHA_OR_TAG"

  project_id = "my-project-id"

  name                  = "project-name"
  region                = "us-central1"
  secrets               = ["app-secret", "app-file-secret"]
  service_account_email = google_service_account.run_service_account.email
  service_iam = {
    admins     = []
    developers = ["serviceAccount:ci-service-account@my-project-id.iam.gserviceaccount.com"]
    invokers   = ["user:test-account-group@google.com"]
  }
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

  # Connecting cloud sql -- public ip version, not recommended due to scaling issues
  # max_instances needs to be set low enough to avoid scaling issues
  # revision_annotations = {
  #   "run.googleapis.com/cloudsql-instances" = google_sql_database_instance.mysql_instance.connection_name
  # }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_revision_annotations"></a> [additional\_revision\_annotations](#input\_additional\_revision\_annotations) | Annotations to add to the template.metadata.annotations field. | `map(string)` | `{}` | no |
| <a name="input_additional_service_annotations"></a> [additional\_service\_annotations](#input\_additional\_service\_annotations) | Annotations to add to the metadata.annotations field. | `map(string)` | `{}` | no |
| <a name="input_args"></a> [args](#input\_args) | Arguments to the cloud run container's entrypoint. | `list(string)` | `[]` | no |
| <a name="input_envvars"></a> [envvars](#input\_envvars) | Environment variables for the Cloud Run service (plain text). | `map(string)` | `{}` | no |
| <a name="input_execution_environment"></a> [execution\_environment](#input\_execution\_environment) | The Cloud Run execution environment, possible values are: gen1, gen2 (defaults to 'gen1'). | `string` | `"gen1"` | no |
| <a name="input_image"></a> [image](#input\_image) | The container image for the Cloud Run service. | `string` | n/a | yes |
| <a name="input_ingress"></a> [ingress](#input\_ingress) | The ingress settings for the Cloud Run service, possible values: all, internal, internal-and-cloud-load-balancing (defaults to 'all'). | `string` | `"all"` | no |
| <a name="input_max_instances"></a> [max\_instances](#input\_max\_instances) | The max number of instances for the Cloud Run service (defaults to '10'). | `string` | `"10"` | no |
| <a name="input_min_instances"></a> [min\_instances](#input\_min\_instances) | The max number of instances for the Cloud Run service (defaults to '0'). | `string` | `"0"` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of this project. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The Google Cloud project ID. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The default Google Cloud region to deploy resources in (defaults to 'us-central1'). | `string` | `"us-central1"` | no |
| <a name="input_resources"></a> [resources](#input\_resources) | The compute resource requests and limits for the Cloud Run service. | <pre>object({<br/>    requests = object({<br/>      cpu    = string<br/>      memory = string<br/>    })<br/>    limits = object({<br/>      cpu    = string<br/>      memory = string<br/>    })<br/>  })</pre> | <pre>{<br/>  "limits": {<br/>    "cpu": "1000m",<br/>    "memory": "512Mi"<br/>  },<br/>  "requests": {<br/>    "cpu": "1000m",<br/>    "memory": "512Mi"<br/>  }<br/>}</pre> | no |
| <a name="input_secret_envvars"></a> [secret\_envvars](#input\_secret\_envvars) | Secret environment variables for the Cloud Run service (Secret Manager). | <pre>map(object({<br/>    name    = string<br/>    version = string<br/>  }))</pre> | `{}` | no |
| <a name="input_secret_volumes"></a> [secret\_volumes](#input\_secret\_volumes) | Volume mounts for the Cloud Run service (Secret Manager). | <pre>map(object({<br/>    name    = string<br/>    version = string<br/>  }))</pre> | `{}` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | Secret Manager secrets to be created with a value of 'DEFAULT\_VALUE'. | `list(any)` | `[]` | no |
| <a name="input_service_account_email"></a> [service\_account\_email](#input\_service\_account\_email) | The service account email for Cloud Run to run as. | `string` | n/a | yes |
| <a name="input_service_iam"></a> [service\_iam](#input\_service\_iam) | IAM member bindings for the Cloud Run service. | <pre>object({<br/>    admins     = list(string)<br/>    developers = list(string)<br/>    invokers   = list(string)<br/>  })</pre> | <pre>{<br/>  "admins": [],<br/>  "developers": [],<br/>  "invokers": []<br/>}</pre> | no |
| <a name="input_startup_probe"></a> [startup\_probe](#input\_startup\_probe) | Optional startup probe configuration | <pre>object({<br/>    initial_delay_seconds = optional(number, 0)<br/>    timeout_seconds       = optional(number, 1)<br/>    period_seconds        = optional(number, 10)<br/>    failure_threshold     = optional(number, 3)<br/>    http_get = optional(object({<br/>      http_headers = optional(map(string), {})<br/>      path         = optional(string)<br/>      port         = optional(number)<br/>    }), null)<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_revision_name"></a> [revision\_name](#output\_revision\_name) | The Cloud Run latest revision name. |
| <a name="output_service_id"></a> [service\_id](#output\_service\_id) | The Cloud Run service id. |
| <a name="output_service_name"></a> [service\_name](#output\_service\_name) | The Cloud Run service name. |
| <a name="output_url"></a> [url](#output\_url) | The Cloud Run service url. |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.83.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.83.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Resources

| Name | Type |
|------|------|
| [google_cloud_run_service.service](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_service) | resource |
| [google_cloud_run_service_iam_binding.admins](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_service_iam_binding) | resource |
| [google_cloud_run_service_iam_binding.developers](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_service_iam_binding) | resource |
| [google_cloud_run_service_iam_binding.invokers](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_run_service_iam_binding) | resource |
| [google_project_iam_member.run_observability_iam](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_service.services](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_secret_manager_secret.secrets](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret) | resource |
| [google_secret_manager_secret_iam_member.secrets_accessors_iam](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_iam_member) | resource |
| [google_secret_manager_secret_version.secrets_default_version](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_version) | resource |
| [random_id.default](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Modules

No modules.
<!-- END_TF_DOCS -->