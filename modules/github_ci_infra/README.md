# abcxyz GitHub CI Infrastructure Module

This module provides the default Google Cloud infrastructre used by GitHub CI for abcxyz projects.

## Example

```terraform
module "github_ci_infra" {
  source                 = "https://github.com/abcxyz/infra/terraform/modules/github_ci_infra"
  project_id             = "my-project-id"
  name                   = "project-name"
  github_repository_name = "repo-name"
}
```
