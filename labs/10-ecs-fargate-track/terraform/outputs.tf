output "alb_dns_name" {
  description = "DNS name of the Fargate application load balancer."
  value       = module.ecs.alb_dns_name
}

output "cluster_name" {
  description = "Name of the ECS cluster."
  value       = module.ecs.cluster_name
}
