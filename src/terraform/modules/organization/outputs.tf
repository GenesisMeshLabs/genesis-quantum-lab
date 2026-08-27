output "organization_root_id" {
  value = local.org_root_id
}

output "organizational_units" {
  description = "Map of OU name -> OU id"
  value       = { for k, v in aws_organizations_organizational_unit.ou : k => v.id }
}

output "member_account_ids" {
  description = "Map of logical account key -> AWS account id"
  value       = { for k, v in aws_organizations_account.member : k => v.id }
}

output "member_account_arns" {
  value = { for k, v in aws_organizations_account.member : k => v.arn }
}
