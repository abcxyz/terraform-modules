locals {
  remote_state = {
    for key, value in data.terraform_remote_state.remote_state : key => value.outputs
  }
}

data "terraform_remote_state" "remote_state" {
  for_each = {
    org      = "{{.bucket_prefix}}/org",
    products = "{{.bucket_prefix}}/products",
  }

  backend = "gcs"

  config = {
    bucket = "{{.bucket_name}}"
    prefix = each.value
  }
}
