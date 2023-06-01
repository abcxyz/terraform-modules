output "folder" {
  value = google_folder.product.name
}

output "environments" {
  value = { for k, v in module.environments : k => v.folder }
}
