#
# This module defines the default configuration for a github respository to
# enable automation capabilities using workload identity federation.
#

locals {
  repo_full_name = "${var.github.owner_name}/${var.github.repo_name}"

  type = var.guardian.enabled ? "guardian" : "automation"

  guardian_workflows = [for workflow in var.guardian.workflows : "${local.repo_full_name}/.github/workflows/${workflow}@refs/heads/${var.github.default_branch}"]

  guardian_wif_attribute_condition = trimspace(chomp(<<-EOF
  attribute.repository_owner_id == "${var.github.owner_id}"
   && attribute.repository_id == "${var.github.repo_id}"
   && attribute.repository_visibility != "public"
   && attribute.workflow_ref in [${join(", ", local.guardian_workflows)}]
  EOF
  ))

  default_wif_attribute_condition = var.guardian.enabled && var.guardian.enable_wif_attribute_condition ? local.guardian_wif_attribute_condition : null
  wif_attribute_condition         = var.override_wif_attribute_condition != null ? var.override_wif_attribute_condition : local.default_wif_attribute_condition
}

module "projects" {
  source = "../product-project"

  project_id = "gh-${var.project_id}" # 30 character limit

  bucket_name        = var.bucket_name
  bucket_root_prefix = var.bucket_root_prefix
  environments       = var.environments
  billing_account    = var.billing_account
  project_services   = var.project_services
}

resource "google_tags_tag_binding" "wif_github" {
  for_each = module.projects.environments

  parent    = "//cloudresourcemanager.googleapis.com/projects/${each.value.project.project_number}"
  tag_value = local.remote_state.org_tags.org_tag_values["workload-identity-federation:github"].id
}

# When creating projects, there is an IAM propagation delay for the CI
# automation account permissions which causes the creation of the WIF
# resources to fail in a consistent manner. This is an attempt to make
# creating these resources consistently succeed. We will wait 45s for
# IAM propagation.
resource "time_sleep" "wait_45s" {
  for_each = module.projects.environments

  create_duration = "45s"

  depends_on = [module.projects]
}

module "github_wif" {
  for_each = module.projects.environments

  source = "../github-wif"

  project_id = each.value.project.project_id

  id     = "${local.type}-${lookup(local.remote_state.org.product_environments[each.key], "short_code")}"
  github = var.github

  wif_attribute_mapping   = var.override_wif_attribute_mapping
  wif_attribute_condition = local.wif_attribute_condition

  depends_on = [time_sleep.wait_45s]
}

module "storage" {
  for_each = var.guardian.enabled ? module.projects.environments : {}

  source = "./modules/guardian-storage"

  project_id = each.value.project.project_id

  id                 = "${local.type}-${lookup(local.remote_state.org.product_environments[each.key], "short_code")}"
  bucket_admin_email = module.github_wif[each.key].service_account_email
}
