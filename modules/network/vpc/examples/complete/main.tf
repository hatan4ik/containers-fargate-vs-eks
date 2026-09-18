terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source = "../../"

  name                    = "example-complete"
  cidr                    = "10.98.0.0/16"
  availability_zones      = slice(data.aws_availability_zones.available.names, 0, 3)
  single_nat_gateway      = false
  flow_log_retention_days = 90
  eks_subnet_tags         = true
  tags = {
    Environment = "example"
    Team        = "platform"
  }
}

output "vpc_id" { value = module.vpc.vpc_id }
output "public_subnet_ids" { value = module.vpc.public_subnet_ids }
output "private_subnet_ids" { value = module.vpc.private_subnet_ids }
