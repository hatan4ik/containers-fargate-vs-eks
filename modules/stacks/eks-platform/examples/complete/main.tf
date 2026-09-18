terraform {
  required_version = ">= 1.6.0, < 2.0.0"
}

provider "aws" {
  region = "us-east-1"
}

module "platform" {
  source = "../.."

  name                         = "example-prod"
  vpc_cidr                     = "10.50.0.0/16"
  availability_zones           = ["us-east-1a", "us-east-1b", "us-east-1c"]
  kubernetes_version           = "1.30"
  node_instance_type           = "m6i.large"
  node_disk_size_gb            = 100
  endpoint_public_access       = true
  endpoint_public_access_cidrs = ["203.0.113.0/24"]
  node_scaling = {
    min     = 2
    desired = 3
    max     = 6
  }
  tags = {
    Environment = "prod"
    Owner       = "platform"
  }
}
