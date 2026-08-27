variable "name" {
  description = "Name prefix, e.g. 'mqh-research-a'."
  type        = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  description = "Private-tier subnet IDs to place the DB subnet group in (needs at least 2, in different AZs)."
  type        = list(string)
}

variable "allowed_security_group_ids" {
  description = "Security groups allowed to connect to the database on the Postgres port (typically the research workload SG)."
  type        = list(string)
}

variable "engine_version" {
  description = "Postgres major/minor version. Ref: 02-Cloud-Infrastructure.md test database sizing."
  type        = string
  default     = "16.4"
}

variable "instance_class" {
  type    = string
  default = "db.t4g.micro"
}

variable "allocated_storage_gb" {
  type    = number
  default = 20
}

variable "database_name" {
  type    = string
  default = "labdb"
}

variable "master_username" {
  type    = string
  default = "labadmin"
}

variable "multi_az" {
  description = "Multi-AZ standby. Off by default to keep lab cost down (proposal cost table assumes single-AZ for research test databases)."
  type        = bool
  default     = false
}

variable "backup_retention_days" {
  type    = number
  default = 7
}

variable "deletion_protection" {
  description = "Set true once this holds anything other than throwaway synthetic data."
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  type    = bool
  default = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
