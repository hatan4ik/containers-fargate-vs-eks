terraform {
  required_version = ">= 1.6.0, < 2.0.0"
}

provider "aws" {
  region = "us-east-1"
}

module "platform" {
  source = "../.."

  name                   = "example-prod"
  vpc_cidr               = "10.50.0.0/16"
  availability_zones     = ["us-east-1a", "us-east-1b", "us-east-1c"]
  kubernetes_version     = "1.30"
  node_instance_type     = "m6i.large"
  node_disk_size_gb      = 100
  flow_log_kms_key_id    = "arn:aws:kms:us-east-1:123456789012:key/replace-me"
  cluster_log_kms_key_id = "arn:aws:kms:us-east-1:123456789012:key/replace-me"
  secrets_kms_key_arn    = "arn:aws:kms:us-east-1:123456789012:key/replace-me"
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
