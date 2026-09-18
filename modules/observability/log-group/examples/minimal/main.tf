terraform {
  required_version = ">= 1.6.0, < 2.0.0"
}

provider "aws" {
  region = "us-east-1"
}

module "log_group" {
  source = "../.."

  name       = "/example-dev/apps"
  kms_key_id = "arn:aws:kms:us-east-1:123456789012:key/replace-me"
}
