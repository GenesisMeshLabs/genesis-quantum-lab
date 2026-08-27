# Phase 2 — AWS Network Firewall for the inspection tier.
# Ref: 02-Cloud-Infrastructure.md "VPC Topology" (Inspection tier: "reserved
# for Network Firewall, all egress routed through here") and
# "Service Approval List". Deployed into the inspection subnets created by
# modules/networking; that module rewires private-subnet egress through the
# firewall endpoints when `enable_network_firewall = true`.
#
# Uses a domain allow-list (strict rule order): only the domains research
# workloads actually need (package indexes, container registries, AWS APIs,
# GitHub) are permitted outbound; everything else is dropped and logged.

resource "aws_networkfirewall_rule_group" "domain_allowlist" {
  name     = "${var.name}-domain-allowlist"
  type     = "STATEFUL"
  capacity = 100

  rule_group {
    rules_source {
      rules_source_list {
        generated_rules_type = "ALLOWLIST"
        target_types         = ["HTTP_HOST", "TLS_SNI"]
        targets              = var.domain_allow_list
      }
    }
  }

  tags = var.tags
}

resource "aws_networkfirewall_firewall_policy" "this" {
  name = "${var.name}-policy"

  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]

    # Domain-list rule groups require strict rule evaluation order, and a
    # strict default action (drop everything not explicitly allow-listed).
    stateful_engine_options {
      rule_order = "STRICT_ORDER"
    }
    stateful_default_actions = ["aws:drop_strict"]

    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.domain_allowlist.arn
      priority     = 1
    }
  }

  tags = var.tags
}

resource "aws_networkfirewall_firewall" "this" {
  name                = "${var.name}-firewall"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.this.arn
  vpc_id              = var.vpc_id

  dynamic "subnet_mapping" {
    for_each = var.inspection_subnet_ids
    content {
      subnet_id = subnet_mapping.value
    }
  }

  tags = var.tags
}

# --- Logging: alerts (dropped/allowed decisions) + flow logs to CloudWatch ---

resource "aws_cloudwatch_log_group" "alerts" {
  name              = "/meta-quantum-harvest/network-firewall/${var.name}/alerts"
  retention_in_days = var.alert_log_retention_days
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "flow" {
  name              = "/meta-quantum-harvest/network-firewall/${var.name}/flow"
  retention_in_days = var.alert_log_retention_days
  tags              = var.tags
}

resource "aws_networkfirewall_logging_configuration" "this" {
  firewall_arn = aws_networkfirewall_firewall.this.arn

  logging_configuration {
    log_destination_config {
      log_destination_type = "CloudWatchLogs"
      log_type             = "ALERT"
      log_destination = {
        logGroup = aws_cloudwatch_log_group.alerts.name
      }
    }
    log_destination_config {
      log_destination_type = "CloudWatchLogs"
      log_type             = "FLOW"
      log_destination = {
        logGroup = aws_cloudwatch_log_group.flow.name
      }
    }
  }
}

# Firewall endpoints are created implicitly, one per inspection subnet /
# AZ. Callers (the networking module) need these endpoint IDs to redirect
# private-subnet 0.0.0.0/0 routes through the firewall.
locals {
  endpoint_by_az = {
    for s in aws_networkfirewall_firewall.this.firewall_status[0].sync_states :
    s.availability_zone => s.attachment[0].endpoint_id
  }
}
