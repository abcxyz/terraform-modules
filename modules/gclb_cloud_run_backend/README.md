# abcxyz Cloud Run Module

This module provides the default Global HTTPS Load Balancer for use with a Cloud Run service as the backend for abcxyz projects.

## Example

```terraform
module "gclb" {
  source           = "https://github.com/abcxyz/infra/terraform/modules/gclb_cloud_run_backend"
  project_id       = "my-project-id"
  name             = "project-name"
  run_service_name = google_service_account.run_service_account.email
  domain           = "project.e2e.tycho.joonix.net"
}
```
