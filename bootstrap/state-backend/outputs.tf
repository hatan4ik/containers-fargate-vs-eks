output "state_bucket_name" {
  description = "Terraform state bucket name for CI backend configuration."
  value       = module.terraform_state.bucket_name
}

output "state_kms_key_id" {
  description = "Terraform state KMS key ID for CI backend configuration."
  value       = module.terraform_state.kms_key_id
}

output "plan_role_arns" {
  description = "Environment-keyed OIDC plan-role ARNs. Configure these as GitHub Environment variables."
  value       = module.github_actions_oidc.plan_role_arns
}

output "apply_role_arns" {
  description = "Environment-keyed OIDC apply-role ARNs. Configure these only after migration verification."
  value       = module.github_actions_oidc.apply_role_arns
}
