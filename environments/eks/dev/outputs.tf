output "cluster_name" {
  description = "Development EKS cluster name."
  value       = module.platform.cluster_name
}

output "cluster_endpoint" {
  description = "Development EKS cluster API endpoint."
  value       = module.platform.cluster_endpoint
}

output "oidc_provider_arn" {
  description = "Development EKS IAM OIDC provider ARN."
  value       = module.platform.oidc_provider_arn
}
