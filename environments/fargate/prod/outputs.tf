output "alb_dns_name" {
  description = "Production application load balancer DNS name."
  value       = module.platform.alb_dns_name
}

output "cluster_name" {
  description = "Production ECS cluster name."
  value       = module.platform.cluster_name
}
