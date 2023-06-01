#
# This module defines the default configuration for a new project
# for a product.
#

module "projects" {
  for_each = var.environments

  source = "../project"

  project_id = "${var.project_id}-${lookup(local.remote_state.org.product_environments[each.key], "short_code")}" # 30 character limit

  folder_name = each.value

  billing_account  = var.billing_account
  project_services = var.project_services
}
