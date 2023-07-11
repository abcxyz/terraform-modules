module "{{.github_owner_name}}_{{replace .project_id "-" "_" -1}}_automation" {
  source = "git::https://github.com/abcxyz/terraform-modules.git//modules/platform/product-project-github?ref=46d3ffd82d7c3080bc5ec2cc788fe3e21176a8be"

  project_id = "{{.project_id}}"

  billing_account    = local.remote_state.org.billing_account
  bucket_name        = local.remote_state.org.terraform_state_bucket
  bucket_root_prefix = local.remote_state.org.terraform_bucket_root_prefix
  environments       = {{if .environments}}[{{range $index, $value := split .environments ","}}{{ if gt $index 0}}, {{end}}"{{$value}}"{{end}}]{{else}}module.product.environments{{end}}
  github = {
    owner_id   = "{{.github_owner_id}}"
    owner_name = "{{.github_owner_name}}"
    repo_id    = "{{.github_repo_id}}"
    repo_name  = "{{.github_repo_name}}"
  }
}
