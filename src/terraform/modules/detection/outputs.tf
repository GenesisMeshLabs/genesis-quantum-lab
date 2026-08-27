output "guardduty_detector_id" {
  value = aws_guardduty_detector.this.id
}

output "security_alerts_topic_arn" {
  value = aws_sns_topic.security_alerts.arn
}

output "guardduty_event_rule_name" {
  value = aws_cloudwatch_event_rule.guardduty_findings.name
}
