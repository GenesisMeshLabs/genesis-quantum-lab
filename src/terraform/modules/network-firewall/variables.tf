variable "name" {
  description = "Name prefix, e.g. 'mqh-research-a'."
  type        = string
}

variable "vpc_id" {
  type = string
}

variable "inspection_subnet_ids" {
  description = "Map of availability zone -> inspection-tier subnet ID (one per AZ)."
  type        = map(string)
}

variable "domain_allow_list" {
  description = "HTTP host / TLS SNI domains research workloads are allowed to reach. Everything else is dropped and logged. Ref: 02-Cloud-Infrastructure.md Service Approval List + PyPI/container registries needed to run the research modules."
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

variable "alert_log_retention_days" {
  type    = number
  default = 90
}

variable "tags" {
  type    = map(string)
  default = {}
}
