locals {
  required_tags = {
    ManagedBy = "terraform"
    Module    = "compute/ecs-cluster"
    Name      = var.name
  }
  tags = merge(var.tags, local.required_tags)
}
