locals {
  # Services that are enabled on all the GCP projects (except for the admin project)
  services = [
    "iam.googleapis.com",
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
  ]

  # Create a list that is the cartesian product of environments and APIs, so we can enable each API on each project.
  # Produces a list of objects each having the two fields below.
  envs_apis_cross_join = flatten([
    for env_name in local.environments : [
      for api in local.services : {
        env_name : env_name,
        api : api,
      }
    ]
  ])
}

resource "google_project_service" "default" {
  for_each = local.envs_apis_cross_join # env:service map

  project = module.{{replace .project_id "-" "_" -1}}.environments[each.key].project_id

  service = each.value

  disable_on_destroy         = false
  disable_dependent_services = false
}
