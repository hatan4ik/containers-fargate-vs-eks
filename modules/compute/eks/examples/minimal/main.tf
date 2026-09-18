terraform {
  required_version = ">= 1.6.0, < 2.0.0"
}

provider "aws" {
  region = "us-east-1"
}

module "eks" {
  source = "../.."

  name                = "example-dev"
  public_subnet_ids   = ["subnet-replace-1", "subnet-replace-2"]
  private_subnet_ids  = ["subnet-replace-3", "subnet-replace-4"]
  secrets_kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/replace-me"
}
