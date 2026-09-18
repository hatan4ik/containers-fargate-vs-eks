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

  name                = "example-minimal"
  cidr                = "10.99.0.0/16"
  availability_zones  = slice(data.aws_availability_zones.available.names, 0, 2)
  flow_log_kms_key_id = "arn:aws:kms:us-east-1:123456789012:key/replace-me"
}

output "vpc_id" { value = module.vpc.vpc_id }
