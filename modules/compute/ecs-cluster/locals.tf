locals {
  effective_cert_arn = var.certificate_arn
  https_enabled      = var.certificate_arn != null

  required_tags = {
    ManagedBy = "terraform"
    Module    = "compute/ecs-cluster"
    Name      = var.name
  }
  tags = merge(var.tags, local.required_tags)
}
