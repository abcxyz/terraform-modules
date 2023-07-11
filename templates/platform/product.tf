module "product" {
  source = "git::https://github.com/abcxyz/terraform-modules.git//modules/platform/product?ref=46d3ffd82d7c3080bc5ec2cc788fe3e21176a8be"

  parent_name            = local.remote_state.products.folder.name
  product_id             = "{{.product_id}}"
  team_group_email       = "{{.team_group_email}}"
  breakglass_group_email = "{{.breakglass_group_email}}"
  bucket_name            = local.remote_state.org.terraform_state_bucket
  bucket_root_prefix     = local.remote_state.org.terraform_bucket_root_prefix
  environments           = [{{range $index, $value := split .environments ","}}{{ if gt $index 0}}, {{end}}"{{$value}}"{{end}}]
}
