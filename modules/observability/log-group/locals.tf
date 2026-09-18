locals {
  required_tags = {
    ManagedBy = "terraform"
    Module    = "observability/log-group"
    Name      = var.name
  }

  tags = merge(var.tags, local.required_tags)
}
