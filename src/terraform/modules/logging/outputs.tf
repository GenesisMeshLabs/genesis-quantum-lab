output "audit_bucket_name" {
  value = aws_s3_bucket.audit.id
}

output "audit_kms_key_arn" {
  value = aws_kms_key.audit.arn
}

output "trail_arn" {
  value = aws_cloudtrail.org.arn
}

output "cloudwatch_log_group_name" {
  value = aws_cloudwatch_log_group.trail.name
}
