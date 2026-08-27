variable "name" {
  description = "Name prefix for network resources, e.g. 'mqh-research-a'."
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block. Proposal default is 10.0.0.0/16 (02-Cloud-Infrastructure.md)."
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability zones to spread subnets across."
  type        = list(string)
}

variable "enable_flow_logs" {
  type    = bool
  default = true
}

variable "flow_log_retention_days" {
  type    = number
  default = 365
}

variable "tags" {
  type    = map(string)
  default = {}
}
