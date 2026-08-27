# Phase 1 & 2 root module for the Security account — run AFTER envs/management.
# Provisions centralized, immutable audit logging (Phase 1) and org-wide
# threat detection / compliance monitoring (Phase 2).

module "logging" {
  source = "../../modules/logging"

  bucket_name = var.audit_bucket_name
  tags        = { Phase = "1-foundation" }
}

module "detection" {
  source = "../../modules/detection"

  config_bucket_name = var.config_bucket_name
  alert_email        = var.alert_email
  tags               = { Phase = "2-lab-infrastructure" }
}
