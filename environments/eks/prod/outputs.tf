output "cluster_name" {
  description = "Production EKS cluster name."
  value       = module.platform.cluster_name
}

output "cluster_endpoint" {
  description = "Production EKS cluster API endpoint."
  value       = module.platform.cluster_endpoint
}

output "oidc_provider_arn" {
  description = "Production EKS IAM OIDC provider ARN."
  value       = module.platform.oidc_provider_arn
}
