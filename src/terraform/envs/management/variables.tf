variable "aws_region" {
  description = "Home region for the management account. Proposal recommends an EU region for Swedish public-sector data residency."
  type        = string
  default     = "eu-north-1" # Stockholm
}

variable "create_organization" {
  description = "Set true only if no AWS Organization exists yet for the account you're applying with."
  type        = bool
  default     = false
}

variable "root_email_domain" {
  description = "Domain used to generate unique member-account root emails."
  type        = string
}

variable "identity_center_instance_arn" {
  description = "ARN of the IAM Identity Center instance (from the console, after one-time enablement). Leave blank to skip permission-set management until Identity Center is enabled."
  type        = string
  default     = ""
}

variable "identity_center_identity_store_id" {
  type    = string
  default = ""
}
