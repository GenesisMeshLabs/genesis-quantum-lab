# Phase 1 root module — run this FIRST, from the AWS Organization's
# management account. Provisions: Organization/OUs/accounts, baseline SCPs,
# and (once Identity Center is enabled in the console) permission sets.
#
# See src/docs/IMPLEMENTATION-STATUS.md for the manual, console-only
# prerequisites (Identity Center enablement, MFA policy) that Terraform
# cannot perform on your behalf.

module "organization" {
  source = "../../modules/organization"

  create_organization = var.create_organization
  root_email_domain   = var.root_email_domain
  tags                = { Phase = "1-foundation" }
}

module "scp" {
  source = "../../modules/scp"

  organization_root_id = module.organization.organization_root_id
  organizational_units = module.organization.organizational_units
}

module "identity_center" {
  count  = var.identity_center_instance_arn != "" ? 1 : 0
  source = "../../modules/identity-center"

  instance_arn      = var.identity_center_instance_arn
  identity_store_id = var.identity_center_identity_store_id
  account_ids       = module.organization.member_account_ids
}
