locals {
  full_name = "${var.name}-${var.service_name}"

  base_environment = [
    { name = "PORT", value = tostring(var.port) },
    { name = "LOG_LEVEL", value = var.log_level },
  ]
  container_environment = concat(local.base_environment, var.environment)

  required_tags = {
    ManagedBy = "terraform"
    Module    = "compute/ecs-service"
    Service   = var.service_name
  }
  tags = merge(var.tags, local.required_tags)
}
