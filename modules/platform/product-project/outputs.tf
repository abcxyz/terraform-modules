output "environments" {
  value = {
    for k, v in var.environments : k => {
      project = module.projects[k]
    }
  }
}
