variable "create_organization" {
  description = "Whether to create a brand-new AWS Organization. Set to false if the org already exists and you only want to manage accounts/OUs."
  type        = bool
  default     = false
}

variable "root_email_domain" {
  description = "Email domain used to build unique root emails for member accounts, e.g. 'yourcompany.com'. Each account needs a unique, real, monitored mailbox (AWS requirement)."
  type        = string
}

variable "account_emails" {
  description = "Explicit email override per account key, if you don't want the auto-generated '<key>+aws@domain' pattern."
  type        = map(string)
  default     = {}
}

variable "member_accounts" {
  description = "Member accounts to create, keyed by logical name. Matches 02-Cloud-Infrastructure.md account structure."
  type = map(object({
    name = string
    ou   = string # one of: security, network, research, sandbox
  }))
  default = {
    security   = { name = "meta-quantum-harvest-security", ou = "security" }
    network    = { name = "meta-quantum-harvest-network", ou = "network" }
    research_a = { name = "meta-quantum-harvest-research-a", ou = "research" }
    research_b = { name = "meta-quantum-harvest-research-b", ou = "research" }
    sandbox    = { name = "meta-quantum-harvest-sandbox", ou = "sandbox" }
  }
}

variable "tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
  default     = {}
}
