locals {
  required_tags = {
    ManagedBy = "terraform"
    Module    = "stacks/eks-platform"
    Name      = var.name
  }

  tags = merge(var.tags, local.required_tags)
}
