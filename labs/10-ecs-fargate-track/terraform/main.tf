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
  source = "./modules/vpc"
  name   = var.name
  cidr   = var.vpc_cidr
}

module "observability" {
  source = "./modules/observability"
  name   = var.name
}

module "ecs" {
  source = "./modules/ecs"
  name   = var.name

  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids

  log_group_name = module.observability.log_group_name

  image_gateway = var.image_gateway
  image_users   = var.image_users
  image_orders  = var.image_orders
}
