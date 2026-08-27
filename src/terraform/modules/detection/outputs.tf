output "guardduty_detector_id" {
  value = aws_guardduty_detector.this.id
}

output "security_alerts_topic_arn" {
  value = aws_sns_topic.security_alerts.arn
}
