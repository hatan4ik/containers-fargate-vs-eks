locals {
  required_tags = {
    ManagedBy = "terraform"
    Module    = "bootstrap/external-ci-oidc"
    Name      = var.name
  }

  tags = merge(var.tags, local.required_tags)
}
