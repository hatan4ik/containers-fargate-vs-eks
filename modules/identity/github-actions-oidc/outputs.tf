output "plan_role_arns" {
  description = "Map of environment key to GitHub OIDC plan-role ARN."
  value       = { for key, role in aws_iam_role.plan : key => role.arn }
}

output "apply_role_arns" {
  description = "Map of environment key to GitHub OIDC apply-role ARN."
  value       = { for key, role in aws_iam_role.apply : key => role.arn }
}

output "github_oidc_provider_arn" {
  description = "GitHub Actions OIDC provider ARN used by the roles."
  value       = local.oidc_provider_arn
}
