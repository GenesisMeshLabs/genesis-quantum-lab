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

variable "enable_network_firewall" {
  description = "Deploy AWS Network Firewall in the inspection tier and route all private-subnet egress through it (domain allow-list). Ref: 02-Cloud-Infrastructure.md VPC Topology 'Inspection: reserved for Network Firewall'."
  type        = bool
  default     = false
}

variable "network_firewall_domain_allow_list" {
  description = "HTTP host / TLS SNI domains research workloads may reach when enable_network_firewall = true. Ignored otherwise."
  type        = list(string)
  default = [
    ".amazonaws.com",
    ".pypi.org",
    "pypi.org",
    "files.pythonhosted.org",
    "github.com",
    ".github.com",
    "githubusercontent.com",
    ".githubusercontent.com",
    "docker.io",
    ".docker.io",
  ]
}

variable "flow_log_retention_days" {
  type    = number
  default = 365
}

variable "tags" {
  type    = map(string)
  default = {}
}
