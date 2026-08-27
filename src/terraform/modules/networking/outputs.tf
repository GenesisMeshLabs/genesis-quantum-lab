output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "management_subnet_ids" {
  value = aws_subnet.management[*].id
}

output "alb_security_group_id" {
  value = aws_security_group.alb.id
}

output "workload_security_group_id" {
  value = aws_security_group.workload.id
}

output "inspection_subnet_ids" {
  value = aws_subnet.inspection[*].id
}

output "network_firewall_arn" {
  description = "ARN of the Network Firewall, when enable_network_firewall = true. Null otherwise."
  value       = var.enable_network_firewall ? module.firewall[0].firewall_arn : null
}

output "network_firewall_alert_log_group_name" {
  description = "CloudWatch Logs group of Network Firewall ALERT logs, when enable_network_firewall = true. Null otherwise."
  value       = var.enable_network_firewall ? module.firewall[0].alert_log_group_name : null
}

output "flow_log_group_name" {
  description = "CloudWatch Logs group of VPC Flow Logs, when enable_flow_logs = true. Null otherwise."
  value       = var.enable_flow_logs ? aws_cloudwatch_log_group.flow_logs[0].name : null
}
