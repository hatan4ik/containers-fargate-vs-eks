module "platform" {
  # Release tag modules-v1.3.0 resolves to this immutable commit.
  source = "git::https://github.com/hatan4ik/containers-fargate-vs-eks.git//modules/stacks/eks-platform?ref=280f2e70959cdb2450ff71dcbc4dd4fabd2c7d5d"

  name                   = local.name_prefix
  vpc_cidr               = var.vpc_cidr
  availability_zones     = var.availability_zones
  single_nat_gateway     = var.single_nat_gateway
  kubernetes_version     = var.kubernetes_version
  node_instance_type     = var.node_instance_type
  node_disk_size_gb      = var.node_disk_size_gb
  node_scaling           = var.node_scaling
  flow_log_kms_key_id    = var.flow_log_kms_key_id
  cluster_log_kms_key_id = var.cluster_log_kms_key_id
  secrets_kms_key_arn    = var.secrets_kms_key_arn
  tags                   = local.tags
}
