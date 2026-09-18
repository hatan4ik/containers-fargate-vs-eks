locals {
  environment = "dev"
  project     = "containers-fargate-vs-eks"

  canonical_name_prefix = "${substr(var.organization, 0, 8)}-${local.environment}-${replace(var.region, "-", "")}"
  name_prefix           = coalesce(var.migration_name_override, local.canonical_name_prefix)

  required_tags = {
    ManagedBy    = "terraform"
    Organization = var.organization
    Project      = local.project
    Environment  = local.environment
    Region       = var.region
  }

  tags = merge(var.tags, local.required_tags)
}
