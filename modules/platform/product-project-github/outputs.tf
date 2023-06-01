output "environments" {
  value = {
    for k, v in var.environments : k => {
      project = module.projects.environments[k].project
      wif     = module.github_wif[k]
      storage = try(module.storage[k], null)
    }
  }
}
