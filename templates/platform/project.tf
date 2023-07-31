# TODO: factor out the "replace ...." ugliness using a go-template variable assignment (is this possible?)
locals {
  environments = {{if .environments}}[{{range $index, $value := split .environments ","}}{{ if gt $index 0}}, {{end}}"{{$value}}"{{end}}]{{else}}module.product.environments{{end}}
}

module "{{replace .project_id "-" "_" -1}}" {
  source = "../../../modules/product-project"

  project_id = "{{.project_id}}"

  billing_account    = local.remote_state.org.billing_account
  bucket_name        = local.remote_state.org.terraform_state_bucket
  bucket_root_prefix = local.remote_state.org.terraform_bucket_root_prefix
  environments       = local.environments
}
