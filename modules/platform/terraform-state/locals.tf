locals {
  required_tags = {
    ManagedBy = "terraform"
    Module    = "platform/terraform-state"
    Name      = var.name
  }

  tags = merge(var.tags, local.required_tags)
}
