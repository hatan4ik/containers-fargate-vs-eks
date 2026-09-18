locals {
  # Stable keys: AZ name (e.g. "us-east-1a") — immune to index shifts when AZ count changes.
  az_keys = toset(var.availability_zones)

  # For NAT: either one gateway keyed "0" or one per AZ.
  nat_keys = var.single_nat_gateway ? toset(["0"]) : local.az_keys

  # Map AZ name -> /24 offset for deterministic CIDR assignment.
  az_public_cidrs  = { for i, az in var.availability_zones : az => cidrsubnet(var.cidr, 8, i) }
  az_private_cidrs = { for i, az in var.availability_zones : az => cidrsubnet(var.cidr, 8, i + 10) }

  flow_log_group_name = coalesce(var.flow_log_group_name, "/${var.name}/vpc-flow-logs")
  flow_log_role_name  = coalesce(var.flow_log_role_name, "${var.name}-vpc-flow-logs")

  public_subnet_tags = var.eks_subnet_tags ? {
    "kubernetes.io/role/elb" = "1"
  } : {}

  private_subnet_tags = var.eks_subnet_tags ? {
    "kubernetes.io/role/internal-elb" = "1"
  } : {}

  required_tags = {
    ManagedBy = "terraform"
    Module    = "network/vpc"
    Name      = var.name
  }
  tags = merge(var.tags, local.required_tags)
}
