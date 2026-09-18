terraform {
  required_version = ">= 1.6.0, < 2.0.0"
}

provider "aws" {
  region = "us-east-1"
}

module "terraform_state" {
  source = "../.."

  name                               = "example-platform"
  bucket_name                        = "example-platform-terraform-state-replace-me"
  noncurrent_version_expiration_days = 730
  tags = {
    Environment = "shared"
    Owner       = "platform"
    CostCenter  = "replace-me"
  }
}
