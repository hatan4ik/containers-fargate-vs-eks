locals {
  required_tags = {
    ManagedBy = "terraform"
    Module    = "stacks/fargate-platform"
    Name      = var.name
  }

  tags = merge(var.tags, local.required_tags)
}
