output "alb_dns_name" {
  description = "Development application load balancer DNS name."
  value       = module.platform.alb_dns_name
}

output "cluster_name" {
  description = "Development ECS cluster name."
  value       = module.platform.cluster_name
}
