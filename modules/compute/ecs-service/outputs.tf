output "service_name" {
  description = "ECS service name."
  value       = aws_ecs_service.this.name
}

output "service_id" {
  description = "ECS service ID."
  value       = aws_ecs_service.this.id
}

output "task_definition_arn" {
  description = "Active task definition ARN."
  value       = aws_ecs_task_definition.this.arn
}

output "security_group_id" {
  description = "Security group ID for this service's tasks."
  value       = aws_security_group.this.id
}

output "service_discovery_arn" {
  description = "Cloud Map service ARN. Null when service discovery is not configured."
  value       = try(aws_service_discovery_service.this[0].arn, null)
}
