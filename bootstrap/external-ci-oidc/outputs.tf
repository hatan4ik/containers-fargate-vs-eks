output "oidc_provider_arns" {
  description = "OIDC provider ARNs keyed by external CI platform."
  value       = { for key, provider in module.provider : key => provider.oidc_provider_arn }
}

output "role_arns" {
  description = "External CI role ARNs keyed first by platform and then stable role key."
  value       = { for key, provider in module.provider : key => provider.role_arns }
}
