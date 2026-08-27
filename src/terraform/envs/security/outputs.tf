output "audit_bucket_name" {
  value = module.logging.audit_bucket_name
}

output "cloudtrail_arn" {
  value = module.logging.trail_arn
}

output "guardduty_detector_id" {
  value = module.detection.guardduty_detector_id
}

output "security_alerts_topic_arn" {
  value = module.detection.security_alerts_topic_arn
}
