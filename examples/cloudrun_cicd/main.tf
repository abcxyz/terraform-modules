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

module "service" {
  source = "git::https://github.com/abcxyz/terraform-modules.git//modules/cloudrun_cicd_service?ref=PUT_LATEST_SHA_OR_TAG_HERE"

  # billing_account should be left blank in the case where you need a human to manually associate
  # your project with a billing account. In that case, terraform will create projects but fail to
  # create resources within those projects. After the projects have been associated with a billing
  # account, re-run terraform to create all remaining resources.
  #
  # If, on the other hand, you have permission to create a project with an associated billing
  # account, you can put it here and terraform will work on the first run.
  billing_account = "123456-1234-123456"

  folder_id              = "123456789012"
  github_owner_id        = 123456 # github.com/your-org
  github_repository_name = "your-repo"
  github_repository_id   = 123456789 # github.com/your-org/your-repo

  service_name                 = "my-hello-service" # Just pick a descriptive name
  artifact_repository_location = "us-west1"
}

module "dev" {
  source                 = "git::https://github.com/abcxyz/terraform-modules.git//modules/cloudrun_cicd_environment?ref=PUT_LATEST_SHA_OR_TAG_HERE"
  svc                    = module.service.resources
  environment_name       = "dev"
  protected_branches     = false
  custom_branch_policies = false
  min_cloudrun_instances = 1
  cloudrun_invokers      = ["user:example@google.com", "domain:example.com", "group:hello-dev-users@example.com"]
  cloudrun_region        = "us-west1"
}

module "staging" {
  source                 = "git::https://github.com/abcxyz/terraform-modules.git//modules/cloudrun_cicd_environment?ref=PUT_LATEST_SHA_OR_TAG_HERE"
  svc                    = module.service.resources
  environment_name       = "staging"
  protected_branches     = false
  custom_branch_policies = false
  cloudrun_invokers      = ["user:example@google.com", "domain:example.com", "group:hello-staging-users@example.com"]
  cloudrun_region        = "us-west1"
}

module "prod" {
  source                   = "git::https://github.com/abcxyz/terraform-modules.git//modules/cloudrun_cicd_environment?ref=PUT_LATEST_SHA_OR_TAG_HERE"
  svc                      = module.service.resources
  environment_name         = "prod"
  cloudrun_region          = "us-west1"
  cloudrun_invokers        = ["allUsers"] # In this example, production is a public service. Maybe yours shouldn't be.
  protected_branches       = true
  custom_branch_policies   = true
  reviewer_user_github_ids = [123456]
  reviewer_team_github_ids = [1234567]
}
