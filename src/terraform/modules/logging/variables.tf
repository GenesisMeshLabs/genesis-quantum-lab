variable "bucket_name" {
  description = "Globally-unique name for the immutable audit log bucket."
  type        = string
}

variable "trail_name" {
  description = "Name of the organization CloudTrail trail."
  type        = string
  default     = "meta-quantum-harvest-org-trail"
}

variable "is_organization_trail" {
  description = "Whether this trail should capture all accounts in the organization. Must be applied from the management account."
  type        = bool
  default     = true
}

variable "log_retention_years" {
  description = "Object Lock retention period in years for audit logs (compliance requires 7 years, see 02-Cloud-Infrastructure.md)."
  type        = number
  default     = 7
}

variable "tags" {
  type    = map(string)
  default = {}
}
