locals {
  remote_state = {
    org      = data.terraform_remote_state.org.outputs
    org_tags = data.terraform_remote_state.org_tags.outputs
  }
}

data "terraform_remote_state" "org" {
  backend = "gcs"

  config = {
    bucket = var.bucket_name
    prefix = "${var.bucket_root_prefix}/org"
  }
}

data "terraform_remote_state" "org_tags" {
  backend = "gcs"

  config = {
    bucket = var.bucket_name
    prefix = "${var.bucket_root_prefix}/org/tags"
  }
}
