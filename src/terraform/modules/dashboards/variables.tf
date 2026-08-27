variable "name" {
  description = "Dashboard name, e.g. 'mqh-security' or 'mqh-research-a'."
  type        = string
}

variable "region" {
  type = string
}

# --- Security-account signals (all optional; pass what applies) ---

variable "guardduty_event_rule_name" {
  description = "Name of the EventBridge rule routing GuardDuty findings to SNS (modules/detection). Adds an invocation-count widget when set."
  type        = string
  default     = null
}

# --- Research-account signals (all optional) ---

variable "flow_log_group_name" {
  description = "CloudWatch Logs group name for VPC Flow Logs (modules/networking output). Adds a rejected-connections Logs Insights widget when set."
  type        = string
  default     = null
}

variable "firewall_alert_log_group_name" {
  description = "CloudWatch Logs group name for Network Firewall alerts (modules/network-firewall output). Adds a dropped-domain Logs Insights widget when set."
  type        = string
  default     = null
}

variable "alb_arn_suffix" {
  description = "ALB ARN suffix (e.g. 'app/mqh-research-a-lab-app/1234567890abcdef') for request/error/latency widgets."
  type        = string
  default     = null
}

variable "ecs_cluster_name" {
  type    = string
  default = null
}

variable "ecs_service_name" {
  type    = string
  default = null
}

variable "rds_instance_id" {
  type    = string
  default = null
}
