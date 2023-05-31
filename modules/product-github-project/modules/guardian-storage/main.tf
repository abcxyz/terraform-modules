resource "random_id" "default" {
  byte_length = 3
}

resource "google_project_service" "storage" {
  project = var.project_id

  service                    = "storage.googleapis.com"
  disable_on_destroy         = false
  disable_dependent_services = false
}

resource "google_storage_bucket" "terraform_state" {
  project = var.project_id

  name                        = "${var.id}-terraform-state-${random_id.default.hex}" # 63 character limit
  location                    = "US"
  force_destroy               = false
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = true
  }

  # keep the 10 latest revisions
  lifecycle_rule {
    condition {
      num_newer_versions = 10
    }
    action {
      type = "Delete"
    }
  }

  depends_on = [google_project_service.storage]
}

# Guardian state bucket
resource "google_storage_bucket" "guardian_state" {
  project = var.project_id

  name                        = "${var.id}-guardian-state-${random_id.default.hex}" # 63 character limit
  location                    = "US"
  force_destroy               = false
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  # delete any files older than 10 days
  lifecycle_rule {
    condition {
      age = 10
    }
    action {
      type = "Delete"
    }
  }

  depends_on = [google_project_service.storage]
}

resource "google_storage_bucket_iam_member" "terraform_state_iam" {
  bucket = google_storage_bucket.terraform_state.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${var.bucket_admin_email}"
}

resource "google_storage_bucket_iam_member" "guardian_state_iam" {
  bucket = google_storage_bucket.guardian_state.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${var.bucket_admin_email}"
}
