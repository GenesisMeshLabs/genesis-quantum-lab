# Phase 1 — AWS Organization & account structure
# Ref: 02-Cloud-Infrastructure.md "Account Structure", 06-Roadmap.md "Week 3-4"
#
# Creates (or attaches to) the AWS Organization, one OU per account family
# (Security, Network, Research, Sandbox), and the member accounts described
# in the proposal. Must be applied from the Organization's management account.

resource "aws_organizations_organization" "this" {
  count = var.create_organization ? 1 : 0

  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "guardduty.amazonaws.com",
    "securityhub.amazonaws.com",
    "sso.amazonaws.com",
    "member.org.stacksets.cloudformation.amazonaws.com",
  ]

  feature_set = "ALL"
}

data "aws_organizations_organization" "existing" {
  count = var.create_organization ? 0 : 1
}

locals {
  org_root_id = var.create_organization ? aws_organizations_organization.this[0].roots[0].id : data.aws_organizations_organization.existing[0].roots[0].id

  ou_names = toset(["Security", "Network", "Research", "Sandbox"])
}

resource "aws_organizations_organizational_unit" "ou" {
  for_each  = local.ou_names
  name      = each.value
  parent_id = local.org_root_id
}

locals {
  ou_key_map = {
    security = "Security"
    network  = "Network"
    research = "Research"
    sandbox  = "Sandbox"
  }
}

resource "aws_organizations_account" "member" {
  for_each = var.member_accounts

  name      = each.value.name
  email     = lookup(var.account_emails, each.key, "${each.key}+aws@${var.root_email_domain}")
  parent_id = aws_organizations_organizational_unit.ou[local.ou_key_map[each.value.ou]].id

  # Accounts are never destroyed automatically by Terraform (AWS requires manual
  # closure); this only removes the account from Terraform state on `destroy`.
  close_on_deletion = false

  tags = merge(var.tags, {
    Project = "meta-quantum-harvest"
    OU      = each.value.ou
  })

  lifecycle {
    ignore_changes = [role_name]
  }
}
