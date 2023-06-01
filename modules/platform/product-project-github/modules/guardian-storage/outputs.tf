output "terraform_state_bucket" {
  value = try(google_storage_bucket.terraform_state.name, null)
}

output "guardian_state_bucket" {
  value = try(google_storage_bucket.guardian_state.name, null)
}
