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

module "cloudrun_cicd" {
  source = "github.com/abcxyz/terraform-modules/modules/cloudrun_cicd_environments"

  billing_account        = "123456-1234-123456"
  folder_id              = "123456789012"
  github_owner_id        = 123456 # github.com/your-org
  github_repository_name = "your-repo"
  github_repository_id   = 123456789 # github.com/your-org/your-repo

  service_name                 = "my-hello-service" # Just pick a descriptive name
  artifact_repository_location = "us-west1"

  deployment_environments = [
    {
      environment_name         = "dev"
      cloudrun_region          = "us-west1"
      environment_type         = "non-prod" # Not publicly reachable
      reviewer_user_github_ids = null
      reviewer_team_github_ids = null
    },
    {
      environment_name         = "staging"
      cloudrun_region          = "us-west1"
      environment_type         = "non-prod" # Not publicly reachable
      reviewer_user_github_ids = null
      reviewer_team_github_ids = null
    },
    {
      environment_name         = "prod"
      cloudrun_region          = "us-west1"
      environment_type         = "prod" # Publicly reachable
      reviewer_user_github_ids = [123456]
      reviewer_team_github_ids = [1234567]
    },
  ]
}
