output "firewall_arn" {
  value = aws_networkfirewall_firewall.this.arn
}

output "firewall_endpoint_by_az" {
  description = "Map of availability zone -> firewall VPC endpoint ID, for wiring into private subnet route tables."
  value       = local.endpoint_by_az
}

output "alert_log_group_name" {
  value = aws_cloudwatch_log_group.alerts.name
}

output "flow_log_group_name" {
  value = aws_cloudwatch_log_group.flow.name
}
