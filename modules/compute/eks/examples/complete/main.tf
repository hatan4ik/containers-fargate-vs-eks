terraform {
  required_version = ">= 1.6.0, < 2.0.0"
}

provider "aws" {
  region = "us-east-1"
}

module "eks" {
  source = "../.."

  name                         = "example-prod"
  public_subnet_ids            = ["subnet-replace-1", "subnet-replace-2"]
  private_subnet_ids           = ["subnet-replace-3", "subnet-replace-4"]
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
