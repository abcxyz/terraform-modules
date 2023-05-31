#
# This module defines the default configuration for a new project
# for a product.
#

locals {
  iac_service_account_iam      = var.iac_service_account_email != null ? { "serviceAccount:${var.iac_service_account_email}" = toset(["roles/editor"]) } : {}
  guardian_service_account_iam = try(local.remote_state.org.guardian_service_account_email, null) != null ? { "serviceAccount:${local.remote_state.org.guardian_service_account_email}" = toset(["roles/owner", "roles/iam.workloadIdentityPoolAdmin"]) } : {}
  project_iam                  = merge(local.iac_service_account_iam, local.guardian_service_account_iam, var.project_iam)
}

module "projects" {
  for_each = var.environments

  source = "../project"

  project_id = "${var.project_id}-${lookup(local.remote_state.org.product_environments[each.key], "short_code")}" # 30 character limit

  folder_name = each.value

  billing_account  = var.billing_account
  project_iam      = local.project_iam
  project_services = var.project_services
}
