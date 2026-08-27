# Phase 2 — CloudWatch dashboard ("SIEM-lite" observability).
# Ref: 02-Cloud-Infrastructure.md "SIEM / CloudWatch dashboards" line item.
#
# This is intentionally built from native CloudWatch metrics + Logs Insights
# queries rather than a full third-party SIEM, matching the lab's minimal-
# footprint approach (04-Security-Policy.md). Every widget is optional and
# only appears when its corresponding module output is wired in, so the same
# module works for both the Security account (GuardDuty signal) and each
# Research/Sandbox account (network/app/db signal).

locals {
  guardduty_widget = var.guardduty_event_rule_name == null ? [] : [{
    type = "metric"
    properties = {
      title  = "GuardDuty findings routed to alerts (EventBridge invocations)"
      region = var.region
      period = 300
      stat   = "Sum"
      metrics = [
        ["AWS/Events", "Invocations", "RuleName", var.guardduty_event_rule_name, { stat = "Sum" }]
      ]
    }
  }]

  flow_log_widget = var.flow_log_group_name == null ? [] : [{
    type = "log"
    properties = {
      title  = "VPC Flow Logs — top rejected connections (last query window)"
      region = var.region
      view   = "table"
      query  = "SOURCE '${var.flow_log_group_name}' | fields @timestamp, srcAddr, dstAddr, dstPort, action | filter action = 'REJECT' | stats count(*) as rejected_count by srcAddr, dstAddr, dstPort | sort rejected_count desc | limit 20"
    }
  }]

  firewall_widget = var.firewall_alert_log_group_name == null ? [] : [{
    type = "log"
    properties = {
      title  = "Network Firewall — dropped domains (allow-list denials)"
      region = var.region
      view   = "table"
      query  = "SOURCE '${var.firewall_alert_log_group_name}' | fields @timestamp, event.alert.signature, event.src_ip, event.dest_ip | sort @timestamp desc | limit 20"
    }
  }]

  alb_widget = var.alb_arn_suffix == null ? [] : [{
    type = "metric"
    properties = {
      title  = "Lab app ALB — requests, 5xx, latency"
      region = var.region
      period = 300
      stat   = "Sum"
      metrics = [
        ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.alb_arn_suffix, { stat = "Sum" }],
        ["AWS/ApplicationELB", "HTTPCode_ELB_5XX_Count", "LoadBalancer", var.alb_arn_suffix, { stat = "Sum" }],
        ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", var.alb_arn_suffix, { stat = "Average" }]
      ]
    }
  }]

  ecs_widget = (var.ecs_cluster_name == null || var.ecs_service_name == null) ? [] : [{
    type = "metric"
    properties = {
      title  = "Lab app ECS service — CPU / memory"
      region = var.region
      period = 300
      stat   = "Average"
      metrics = [
        ["AWS/ECS", "CPUUtilization", "ClusterName", var.ecs_cluster_name, "ServiceName", var.ecs_service_name, { stat = "Average" }],
        ["AWS/ECS", "MemoryUtilization", "ClusterName", var.ecs_cluster_name, "ServiceName", var.ecs_service_name, { stat = "Average" }]
      ]
    }
  }]

  rds_widget = var.rds_instance_id == null ? [] : [{
    type = "metric"
    properties = {
      title  = "Research test database — CPU / connections / free storage"
      region = var.region
      period = 300
      stat   = "Average"
      metrics = [
        ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.rds_instance_id, { stat = "Average" }],
        ["AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", var.rds_instance_id, { stat = "Average" }],
        ["AWS/RDS", "FreeStorageSpace", "DBInstanceIdentifier", var.rds_instance_id, { stat = "Average" }]
      ]
    }
  }]

  raw_widgets = concat(
    local.guardduty_widget,
    local.flow_log_widget,
    local.firewall_widget,
    local.alb_widget,
    local.ecs_widget,
    local.rds_widget,
  )

  # Single-column layout, stacked top to bottom — simplest thing that can't overlap.
  widgets = [
    for idx, w in local.raw_widgets : merge(w, { x = 0, y = idx * 6, width = 24, height = 6 })
  ]
}

resource "aws_cloudwatch_dashboard" "this" {
  dashboard_name = var.name
  dashboard_body = jsonencode({ widgets = local.widgets })
}
