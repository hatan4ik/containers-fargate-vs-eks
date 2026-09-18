terraform {
  required_version = ">= 1.6.0, < 2.0.0"
}

provider "aws" {
  region = "us-east-1"
}

module "platform" {
  source = "../.."

  name                   = "example-dev"
  vpc_cidr               = "10.50.0.0/16"
  availability_zones     = ["us-east-1a", "us-east-1b"]
  flow_log_kms_key_id    = "arn:aws:kms:us-east-1:000000000000:key/example-flow-logs-key"
  cluster_log_kms_key_id = "arn:aws:kms:us-east-1:000000000000:key/example-cluster-logs-key"
  secrets_kms_key_arn    = "arn:aws:kms:us-east-1:000000000000:key/example-secrets-key"
}
