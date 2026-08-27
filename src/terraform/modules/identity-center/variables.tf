variable "identity_store_id" {
  description = "IAM Identity Center identity store id. Identity Center itself must already be enabled in the management account (console-only, one-time setup) before Terraform can manage permission sets."
  type        = string
}

variable "instance_arn" {
  description = "IAM Identity Center instance ARN."
  type        = string
}

variable "account_ids" {
  description = "Map of account key -> account id that permission sets should be assignable against."
  type        = map(string)
}

variable "session_duration" {
  description = "Max session duration per 02-Cloud-Infrastructure.md (1 hour default, 4 hours max for sensitive ops)."
  type        = string
  default     = "PT1H"
}

variable "assignments" {
  description = "Optional: which principal (user/group in Identity Center) gets which permission set on which account. Leave empty until your Identity Center users/groups exist."
  type = list(object({
    permission_set = string
    account_key    = string
    principal_id   = string
    principal_type = string # "USER" or "GROUP"
  }))
  default = []
}
