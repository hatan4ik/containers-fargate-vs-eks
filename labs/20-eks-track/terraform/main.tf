terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = ">= 5.0" }
  }
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source                  = "./modules/vpc"
  name                    = var.name
  cidr                    = var.vpc_cidr
  flow_log_group_name     = "/${var.name}/eks-vpc-flow-logs"
  flow_log_role_name      = "${var.name}-eks-vpc-flow-logs"
  single_nat_gateway      = var.single_nat_gateway
  availability_zone_count = var.availability_zone_count
}

module "observability" {
  source       = "./modules/observability"
  name         = var.name
  cluster_name = "${var.name}-eks"
}

module "eks" {
  source = "./modules/eks"

  name               = var.name
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids

  endpoint_public_access       = var.endpoint_public_access
  endpoint_public_access_cidrs = var.endpoint_public_access_cidrs

  depends_on = [module.observability]
}
