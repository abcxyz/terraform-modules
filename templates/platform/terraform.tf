terraform {
  required_version = ">= 1.0"

  backend "gcs" {
    bucket = "{{.bucket_name}}"
    prefix = "{{.bucket_prefix}}/products/{{.product_id}}"
  }

  required_providers {
    google = {
      version = ">= 4.45"
      source  = "hashicorp/google"
    }
  }
}

provider "google" {}
