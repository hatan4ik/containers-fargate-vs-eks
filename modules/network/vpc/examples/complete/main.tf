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

module "vpc" {
  source = "../../"

  name                    = "example-complete"
  cidr                    = "10.98.0.0/16"
  availability_zones      = ["us-east-1a", "us-east-1b", "us-east-1c"]
  single_nat_gateway      = false
  flow_log_retention_days = 365
  flow_log_kms_key_id     = "arn:aws:kms:us-east-1:123456789012:key/replace-me"
  eks_subnet_tags         = true
  tags = {
    Environment = "example"
    Team        = "platform"
  }
}

output "vpc_id" { value = module.vpc.vpc_id }
output "public_subnet_ids" { value = module.vpc.public_subnet_ids }
output "private_subnet_ids" { value = module.vpc.private_subnet_ids }
