locals {
  remote_state = {
    for key, value in data.terraform_remote_state.remote_state : key => value.outputs
  }
}

data "terraform_remote_state" "remote_state" {
  for_each = {
    org = "${var.bucket_root_prefix}/org",
  }

  backend = "gcs"

  config = {
    bucket = var.bucket_name
    prefix = each.value
  }
}
