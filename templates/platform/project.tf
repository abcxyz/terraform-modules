module "{{replace .project_id "-" "_" -1}}" {
  source = "git::https://github.com/abcxyz/terraform-modules.git//modules/platform/product-project?ref=46d3ffd82d7c3080bc5ec2cc788fe3e21176a8be"

  project_id = "{{.project_id}}"

  billing_account    = local.remote_state.org.billing_account
  bucket_name        = local.remote_state.org.terraform_state_bucket
  bucket_root_prefix = local.remote_state.org.terraform_bucket_root_prefix
  environments       = {{if .environments}}[{{range $index, $value := split .environments ","}}{{ if gt $index 0}}, {{end}}"{{$value}}"{{end}}]{{else}}module.product.environments{{end}}
}
