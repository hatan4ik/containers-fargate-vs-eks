output "cluster_id" {
  description = "ECS cluster ID."
  value       = aws_ecs_cluster.this.id
}

output "cluster_name" {
  description = "ECS cluster name."
  value       = aws_ecs_cluster.this.name
}

output "alb_arn" {
  description = "ALB ARN."
  value       = aws_lb.this.arn
}

output "alb_dns_name" {
  description = "ALB DNS name."
  value       = aws_lb.this.dns_name
}

output "alb_zone_id" {
  description = "ALB hosted zone ID (for Route 53 alias records)."
  value       = aws_lb.this.zone_id
}

output "alb_sg_id" {
  description = "ALB security group ID."
  value       = aws_security_group.alb.id
}

output "gateway_target_group_arn" {
  description = "Target group ARN for the gateway service."
  value       = aws_lb_target_group.gateway.arn
}

output "http_listener_arn" {
  description = "HTTP listener ARN."
  value       = aws_lb_listener.http.arn
}

output "https_listener_arn" {
  description = "HTTPS listener ARN. Null when no certificate is configured."
  value       = try(aws_lb_listener.https[0].arn, null)
}

output "task_execution_role_arn" {
  description = "ECS task execution IAM role ARN (shared by all services)."
  value       = aws_iam_role.task_execution.arn
}

output "task_role_arn" {
  description = "ECS task IAM role ARN (shared by all services)."
  value       = aws_iam_role.task.arn
}

output "service_discovery_namespace_id" {
  description = "Cloud Map private DNS namespace ID."
  value       = aws_service_discovery_private_dns_namespace.ns.id
}

output "service_discovery_namespace_name" {
  description = "Cloud Map private DNS namespace name (e.g. z2h-dev.local)."
  value       = aws_service_discovery_private_dns_namespace.ns.name
}

output "acm_certificate_arn" {
  description = "Provided ACM certificate ARN in use. Null when explicitly HTTP-only."
  value       = local.effective_cert_arn
}
