locals {
  required_tags = {
    ManagedBy = "terraform"
    Module    = "compute/eks"
    Name      = var.name
  }
  tags = merge(var.tags, local.required_tags)
}
