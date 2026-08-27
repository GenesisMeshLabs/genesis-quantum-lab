output "permission_set_arns" {
  value = { for k, v in aws_ssoadmin_permission_set.role : k => v.arn }
}
