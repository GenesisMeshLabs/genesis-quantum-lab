variable "organizational_units" {
  description = "Map of OU name (security/network/research/sandbox) -> OU id, from the organization module output."
  type        = map(string)
}

variable "organization_root_id" {
  description = "Organization root id, used to attach org-wide baseline guardrails."
  type        = string
}
