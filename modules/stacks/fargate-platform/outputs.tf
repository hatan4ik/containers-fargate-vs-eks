output "alb_dns_name" {
  description = "Application load balancer DNS name."
  value       = module.cluster.alb_dns_name
}

output "cluster_name" {
  description = "ECS cluster name."
  value       = module.cluster.cluster_name
}

output "vpc_id" {
  description = "Workload VPC ID."
  value       = module.vpc.vpc_id
}

output "service_names" {
  description = "Stable ECS service names keyed by application component."
  value = {
    gateway = module.gateway.service_name
    orders  = module.orders.service_name
    users   = module.users.service_name
  }
}
