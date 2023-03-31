# abcxyz Cloud Run Module

This module provides the default Global HTTPS Load Balancer for use with a Cloud Run service as the backend for abcxyz projects.

## Example

```terraform
module "gclb" {
  source           = "https://github.com/abcxyz/infra/terraform/modules/gclb_cloud_run_backend"
  project_id       = "my-project-id"
  name             = "project-name"
  run_service_name = google_service_account.run_service_account.email
  domains           = ["project.e2e.tycho.joonix.net"]
}
```

## Updating Certificates

Update the `domains` variable by adding any additional domains you want to redirect to your load balancer. 

1. Make sure to provide the load balancer's IP address (provided as an output of this module) to your domain record managed by DNS. Failure to do so can cause a prolonged outage.
2. Provide your entries into the `domains` list in order to provision a cert, forwarding rule, and target proxy. The order of the `domains` list matters, if you change the order of the existing domains this will cause a new certificate to be created. i.e. `[A, B]` to `[B, A]` will trigger a new cert to be created.
3. New resources will be provisioned based on the latest `domains` list. The prevous certificate that managed the previous list of domains will be removed. This will cause a temporary outage until the new cert is provisioned which takes at most 1 hour.
4. Apply the terraform using this module, monitor your new certificate in the console and wait for it to say "ACTIVE" next to the status of each domain in the list. Find this on the "Certificate Manager" page or by viewing your load balancer configuration in the console. 
5. Once the status is confirmed your new certificate is up and running.
