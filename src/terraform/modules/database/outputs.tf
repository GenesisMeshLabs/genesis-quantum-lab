output "db_instance_id" {
  value = aws_db_instance.this.id
}

output "endpoint" {
  value = aws_db_instance.this.endpoint
}

output "master_user_secret_arn" {
  description = "Secrets Manager ARN holding the RDS-managed master credential. Fetch with aws secretsmanager get-secret-value, never stored in Terraform state."
  value       = aws_db_instance.this.master_user_secret[0].secret_arn
}

output "security_group_id" {
  value = aws_security_group.db.id
}
