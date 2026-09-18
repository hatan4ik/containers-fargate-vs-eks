module "platform" {
  source = "git::https://github.com/hatan4ik/containers-fargate-vs-eks.git//modules/stacks/eks-platform?ref=modules-v1.1.0"

  name                         = local.name_prefix
  vpc_cidr                     = var.vpc_cidr
  availability_zones           = var.availability_zones
  single_nat_gateway           = var.single_nat_gateway
  kubernetes_version           = var.kubernetes_version
  node_instance_type           = var.node_instance_type
  node_disk_size_gb            = var.node_disk_size_gb
  node_scaling                 = var.node_scaling
  endpoint_public_access       = var.endpoint_public_access
  endpoint_public_access_cidrs = var.endpoint_public_access_cidrs
  tags                         = local.tags
}
