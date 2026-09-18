module "vpc" {
  source = "../../network/vpc"

  name                    = var.name
  cidr                    = var.vpc_cidr
  availability_zones      = var.availability_zones
  single_nat_gateway      = var.single_nat_gateway
  flow_log_group_name     = var.flow_log_group_name
  flow_log_role_name      = var.flow_log_role_name
  flow_log_retention_days = var.flow_log_retention_days
  flow_log_kms_key_id     = var.flow_log_kms_key_id
  eks_subnet_tags         = true
  tags                    = local.tags
}

module "cluster_logs" {
  source = "../../observability/log-group"

  name           = "/aws/eks/${var.name}-eks/cluster"
  retention_days = var.cluster_log_retention_days
  kms_key_id     = var.cluster_log_kms_key_id
  tags           = local.tags
}

module "eks" {
  source = "../../compute/eks"

  name                = var.name
  public_subnet_ids   = module.vpc.public_subnet_id_list
  private_subnet_ids  = module.vpc.private_subnet_id_list
  kubernetes_version  = var.kubernetes_version
  node_instance_type  = var.node_instance_type
  node_disk_size_gb   = var.node_disk_size_gb
  node_scaling        = var.node_scaling
  secrets_kms_key_arn = var.secrets_kms_key_arn
  tags                = local.tags

  depends_on = [module.cluster_logs]
}
