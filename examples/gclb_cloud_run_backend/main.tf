module "gclb_cloud_run_backend" {
  source = "git::https://github.com/abcxyz/terraform-modules.git//modules/gclb_cloud_run_backend?ref=SHA_OR_TAG"

  project_id = "my-project-id"

  name             = "project-name"
  run_service_name = "service-name"
  domains          = ["project.company.domain.com"]

  # Sample 50% of requests for tracing.
  trace_sampling_rate = 0.5
}
