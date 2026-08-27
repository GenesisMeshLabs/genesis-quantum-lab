# Phase 1 — IAM Identity Center permission sets
# Ref: 02-Cloud-Infrastructure.md "Identity" (Architect, Security Engineer,
#      Researcher, Operations, Auditor roles; MFA required; 1h/4h sessions)
#
# NOTE: Enabling IAM Identity Center itself is a one-time, console-only action
# in the management account (AWS does not expose "enable Identity Center" as a
# Terraform resource). Once enabled, everything below is Terraform-managed.
# MFA enforcement is configured on the Identity Center instance itself
# (Settings -> Authentication) — also console/API-only today, tracked in
# src/docs/IMPLEMENTATION-STATUS.md as a manual Phase 1 checklist item.

locals {
  permission_sets = {
    Architect = {
      description  = "Cloud/security architecture design authority"
      managed_arns = ["arn:aws:iam::aws:policy/PowerUserAccess"]
    }
    SecurityEngineer = {
      description  = "Security tooling, findings triage, guardrail management"
      managed_arns = ["arn:aws:iam::aws:policy/SecurityAudit", "arn:aws:iam::aws:policy/IAMReadOnlyAccess"]
    }
    Researcher = {
      description  = "Runs approved experiments inside Research accounts only"
      managed_arns = ["arn:aws:iam::aws:policy/ReadOnlyAccess", "arn:aws:iam::aws:policy/AmazonBraketFullAccess"]
    }
    Operations = {
      description  = "Day-to-day lab operations and maintenance"
      managed_arns = ["arn:aws:iam::aws:policy/PowerUserAccess"]
    }
    Auditor = {
      description  = "Read-only, cross-account audit access"
      managed_arns = ["arn:aws:iam::aws:policy/SecurityAudit", "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"]
    }
  }
}

resource "aws_ssoadmin_permission_set" "role" {
  for_each         = local.permission_sets
  name             = each.key
  description      = each.value.description
  instance_arn     = var.instance_arn
  session_duration = var.session_duration
}

resource "aws_ssoadmin_managed_policy_attachment" "role" {
  for_each = {
    for pair in flatten([
      for role, cfg in local.permission_sets : [
        for arn in cfg.managed_arns : { key = "${role}-${arn}", role = role, arn = arn }
      ]
    ]) : pair.key => pair
  }

  instance_arn       = var.instance_arn
  managed_policy_arn = each.value.arn
  permission_set_arn = aws_ssoadmin_permission_set.role[each.value.role].arn
}

# Every permission set additionally gets an inline "least privilege baseline"
# policy that blocks self-privilege-escalation regardless of the managed
# policy attached above.
resource "aws_ssoadmin_permission_set_inline_policy" "guardrail" {
  for_each           = local.permission_sets
  instance_arn       = var.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.role[each.key].arn
  inline_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "DenySelfPrivilegeEscalation"
      Effect   = "Deny"
      Action   = ["iam:CreateAccessKey", "iam:CreateLoginProfile", "iam:UpdateLoginProfile", "iam:AttachUserPolicy", "iam:PutUserPolicy"]
      Resource = "*"
    }]
  })
}

resource "aws_ssoadmin_account_assignment" "this" {
  for_each = { for a in var.assignments : "${a.permission_set}-${a.account_key}-${a.principal_id}" => a }

  instance_arn       = var.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.role[each.value.permission_set].arn
  principal_id       = each.value.principal_id
  principal_type     = each.value.principal_type
  target_id          = var.account_ids[each.value.account_key]
  target_type        = "AWS_ACCOUNT"
}
