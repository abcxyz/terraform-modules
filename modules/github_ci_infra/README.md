# abcxyz GitHub CI Infrastructure Module

This module provides the default Google Cloud infrastructre used by GitHub CI for abcxyz projects.

## Example

```terraform
module "github_ci_infra" {
  source = "git::https://github.com/abcxyz/terraform-modules.git//modules/github_ci_infra?ref=SHA_OR_TAG"

  project_id           = "my-project-id"
  name                 = "project-name"
  github_owner_id      = 123456
  github_repository_id = 123456789
}
```
