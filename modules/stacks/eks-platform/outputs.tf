output "cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS Kubernetes API endpoint."
  value       = module.eks.cluster_endpoint
}

output "oidc_provider_arn" {
  description = "IAM OIDC provider ARN for IAM roles for service accounts."
  value       = module.eks.oidc_provider_arn
}

output "vpc_id" {
  description = "Workload VPC ID."
  value       = module.vpc.vpc_id
}
