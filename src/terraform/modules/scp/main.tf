# Phase 1 — Service Control Policies (guardrails)
# Ref: 02-Cloud-Infrastructure.md "Security Baseline", 04-Security-Policy.md "Mandatory Controls"
#
# Baseline SCPs are attached at the organization root (apply to every account).
# The sandbox-isolation SCP is attached only to the Sandbox OU, enforcing that
# intentionally-vulnerable lab workloads can never bridge into other accounts —
# this is the technical control behind the "lab-only, no external targets" rule
# in swedish-government-aws-playground-proposal.md.

locals {
  baseline_policies = {
    deny_root_user            = "deny-root-user.json"
    deny_leave_org            = "deny-leave-organization.json"
    deny_disable_security     = "deny-disable-security-services.json"
    require_imdsv2_and_region = "require-imdsv2-and-region-restriction.json"
  }
}

resource "aws_organizations_policy" "baseline" {
  for_each = local.baseline_policies

  name    = "mqh-baseline-${replace(each.key, "_", "-")}"
  type    = "SERVICE_CONTROL_POLICY"
  content = file("${path.module}/policies/${each.value}")
}

resource "aws_organizations_policy_attachment" "baseline_root" {
  for_each  = local.baseline_policies
  policy_id = aws_organizations_policy.baseline[each.key].id
  target_id = var.organization_root_id
}

resource "aws_organizations_policy" "sandbox_isolation" {
  name    = "mqh-sandbox-isolation"
  type    = "SERVICE_CONTROL_POLICY"
  content = file("${path.module}/policies/sandbox-isolation.json")
}

resource "aws_organizations_policy_attachment" "sandbox_isolation" {
  policy_id = aws_organizations_policy.sandbox_isolation.id
  target_id = var.organizational_units["sandbox"]
}
