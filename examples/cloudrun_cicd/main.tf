# Copyright 2023 The Authors (see AUTHORS file)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This block of locals contains parameters that are expected to be changed by users.
locals {
  # If you already have all your GCP projects created outside of terraform, you don't need to set 
  # the billing_account variable.
  #
  # If you want terraform to create your projects for you, you *might* need to set billing_account.
  # For many Alphabet users, it's not possible to create GCP projects with a billing account
  # attached, for policy reasons. For those users, they'll need to create their GCP projects
  # without a billing account, then follow a manual human process to associate those projects with
  # a billing account. To do this, set billing_account to null. This will create your projects
  # without an associated billing account, at which point you can ask the necessary human to
  # associate the billing account.
  #
  # If, on the other hand, you have permission to create a project with an associated billing
  # account, you can set billing_account to a real valueand terraform will work on the first run.
  # billing_account = "009DE6-A7C95A-2AEE97"
  billing_account = null

  infra_folder   = "1111111111"
  prod_folder    = "2222222222"
  nonprod_folder = "3333333333"

  github_owner_id              = 123123      # github.com/your-org
  github_repository_name       = "your-repo" # github.com/your-org/your-repo
  github_repository_id         = 123123123   # github.com/your-org/your-repo
  umbrella_service_name        = "my-service"
  artifact_repository_location = "us-west1"

  # You probably want to leave this. This image will be replaced by your real application image
  # the first time you do a rollout.
  initial_container_image = "us-docker.pkg.dev/cloudrun/container/hello"

  # Services that are enabled on all the GCP projects (except for the admin project)
  serving_project_services = [
    "iam.googleapis.com",
    "run.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iamcredentials.googleapis.com",
    "serviceusage.googleapis.com",
  ]

  environments = {
    "dev" : {
      folder_id       = local.nonprod_folder
      cloudrun_region = "us-west1"
      microservices = {
        "hello-svc" : {
          min_cloudrun_instances = 1
          # Cloud Run ingress, https://cloud.google.com/run/docs/securing/ingress
          ingress = "all"
          # Cloud Run invokers, https://cloud.google.com/run/docs/securing/managing-access
          invokers = ["user:alice@your-domain.com", "group:devs@your-domain.com"]
        }
        "bonjour-svc" : {
          min_cloudrun_instances = 1
          ingress                = "all"
          invokers               = ["user:alice@your-domain.com", "group:devs@your-domain.com"]
        }
      }
    }
    "staging" : {
      folder_id       = local.nonprod_folder
      cloudrun_region = "us-west1"
      microservices = {
        "hello-svc" : {
          min_cloudrun_instances = 1
          ingress                = "all"
          invokers               = ["user:alice@your-domain.com", "group:devs@your-domain.com"]
        }
        "bonjour-svc" : {
          min_cloudrun_instances = 1
          ingress                = "all"
          invokers               = ["user:alice@your-domain.com", "group:devs@your-domain.com"]
        }
      }
    }
    "prod" : {
      folder_id       = local.prod_folder
      cloudrun_region = "us-central1"
      microservices = {
        "hello-svc" : {
          min_cloudrun_instances = 3
          # invokers               = ["allUsers"] # Do this to be publicly accessible
          invokers = ["user:alice@your-domain.com", "group:devs@your-domain.com"]
          ingress  = "all"
        }
        "bonjour-svc" : {
          min_cloudrun_instances = 3
          invokers               = ["user:alice@your-domain.com", "group:devs@your-domain.com", "domain:your-domain.com"]
          ingress                = "all"
        }
      }
    }
  }
}

#### GCP project configuration
# You can either create your GCP projects inside terraform (option 1 below), or use
# projects that have already been created outside of terraform and provide their IDs (option 2
# below).
#
#### Option 1: create your GCP projects in terraform:
# locals {
#  # Avoid project ID squatting by using a randomized name.
#  trunc_rand_umbrella_name = "${substr(local.umbrella_service_name, 0, 15)}-${random_id.default.hex}" # Part of project ID. Length 20, allows 10 more for environment name to reach limit 30.
#   # Option 1: create projects in terraform
#   infra_project_id = "${local.trunc_rand_umbrella_name}-infra" # 30 character limit
#   serving_project_ids = {
#     for env_name, env in local.environments: env_name => "${local.trunc_rand_umbrella_name}-${env_name}"
#   }
# }
# resource "random_id" "default" {
#   byte_length = 2
# }
# resource "google_project" "infra_project" {
#   project_id = local.infra_project_id
#   name = local.infra_project_id

#   folder_id       = local.nonprod_folder
#   billing_account = local.billing_account

#   lifecycle {
#     # We expect billing_account association to be done by a human after project creation in the common case.
#     ignore_changes = [billing_account]
#   }
# }
# resource "google_project" "serving_projects" {
#   for_each = local.environments

#   billing_account = local.billing_account
#   folder_id       = each.value.folder_id
#   project_id      = "${local.trunc_rand_umbrella_name}-${each.key}"
#   name            = "${local.trunc_rand_umbrella_name}-${each.key}"

#   lifecycle {
#     # billing_account association might change after creation, if a human is doing the association between projects and billing accounts.
#     ignore_changes = [billing_account]
#   }
# }
#
#### Option 2: use projects created outside of terraform and provide their IDs
locals {
  infra_project_id = "infra-project-id-already-exists"
  serving_project_ids = {
    "dev"     = "dev-project-id-already-exists"
    "staging" = "staging-project-id-already-exists"
    "prod"    = "prod-project-id-already-exists"
  }
}
#### End of GCP project creation

locals {
  # Create a list that is the cartesian product of environments and APIs, so we can enable each API on each project.
  # Produces a list of object each having the two fields below.
  envs_apis_cross_join = flatten([
    for env_name, env in local.environments : [
      for api in local.serving_project_services : {
        env_name : env_name,
        api : api,
      }
    ]
  ])
}

resource "google_project_service" "default" {
  for_each = {
    for ps in local.envs_apis_cross_join : "${ps.env_name}-${ps.api}" => ps
  }

  project = local.serving_project_ids[each.value.env_name]

  service = each.value.api
}

# Create the WIF pool, artifact registry, and service account.
module "github_ci_access_config" {
  source = "git::https://github.com/abcxyz/terraform-modules.git//modules/github_ci_infra?ref=SHA_OR_TAG_HERE"

  project_id = local.infra_project_id

  github_owner_id        = local.github_owner_id
  github_repository_id   = local.github_repository_id
  name                   = local.umbrella_service_name
  registry_repository_id = substr("${local.umbrella_service_name}-images", 0, 63)
  registry_location      = local.artifact_repository_location
}

data "google_project" "serving_project_numbers" {
  for_each   = local.environments
  project_id = local.serving_project_ids[each.key]
}

resource "google_project_service_identity" "cloudrun_agent" {
  for_each = local.environments
  provider = google-beta

  project = local.serving_project_ids[each.key]

  service = "run.googleapis.com"
}

# The Cloud Run Service Agent must have read access to the GAR repo to run the docker images. 
resource "google_artifact_registry_repository_iam_member" "cloudrun_sa_gar_reader" {
  for_each = local.environments

  project = local.infra_project_id

  location   = module.github_ci_access_config.artifact_repository_location
  repository = module.github_ci_access_config.artifact_repository_id
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_project_service_identity.cloudrun_agent[each.key].email}"
  depends_on = [
    module.cloud_run_service
  ]
}

locals {
  # Join each environment with its microservices so we can provision resources per-microservice.
  # Produces a list of objects, each object having the 4 fields below.
  envs_microservices = flatten([
    for env_name, env in local.environments : [
      for microservice_name, microservice in env.microservices : [
        {
          env_name : env_name
          env : env
          microservice_name : microservice_name
          microservice : microservice
        }
      ]
    ]
  ])
}

resource "google_service_account" "cloudrun_service_account" {
  for_each = {
    for em in local.envs_microservices : "${em.env_name}-${em.microservice_name}" => em
  }

  project = local.serving_project_ids[each.value.env_name]

  account_id = substr("${each.value.microservice_name}-cloudrun-sa", 0, 30)
}

module "cloud_run_service" {
  for_each = {
    for em in local.envs_microservices : "${em.env_name}-${em.microservice_name}" => em
  }

  source = "git::https://github.com/abcxyz/terraform-modules.git//modules/cloud_run?ref=SHA_OR_TAG_HERE"

  project_id = local.serving_project_ids[each.value.env_name]

  region                = each.value.env.cloudrun_region
  name                  = each.value.microservice_name
  min_instances         = each.value.microservice.min_cloudrun_instances
  ingress               = each.value.microservice.ingress
  image                 = local.initial_container_image
  service_account_email = google_service_account.cloudrun_service_account[each.key].email
  service_iam = {
    admins     = []
    developers = [module.github_ci_access_config.service_account_member]
    invokers   = each.value.microservice.invokers
  }
}

# In order for the CI service account to be able to deploy new releases to the cloud run services, it
# must have the serviceAccountUser role on the cloud run service accounts.
resource "google_service_account_iam_member" "impersonate" {
  for_each = {
    for em in local.envs_microservices : "${em.env_name}-${em.microservice_name}" => em
  }

  service_account_id = google_service_account.cloudrun_service_account[each.key].name
  role               = "roles/iam.serviceAccountUser"
  member             = module.github_ci_access_config.service_account_member
}

# Set repository-level secrets on the GitHub repo that can be used by CI/CD workflows.
module "github_vars" {
  source = "git::https://github.com/abcxyz/terraform-modules/modules/github_cicd_workflow_vars?ref=SHA_OR_TAG_HERE"

  infra_project_id             = local.infra_project_id
  github_repository_name       = local.github_repository_name
  wif_provider_name            = module.github_ci_access_config.wif_provider_name
  service_account_email        = module.github_ci_access_config.service_account_email
  artifact_repository_id       = module.github_ci_access_config.artifact_repository_id
  artifact_repository_location = module.github_ci_access_config.artifact_repository_location
}
