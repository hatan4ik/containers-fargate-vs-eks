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
  access_log_bucket_name             = "example-platform-audit-logs-replace-me"
  replica_bucket_arn                 = "arn:aws:s3:::example-platform-state-replica-replace-me"
  replica_kms_key_arn                = "arn:aws:kms:us-west-2:123456789012:key/replace-me"
  kms_key_account_root_arn           = "arn:aws:iam::123456789012:root"
  noncurrent_version_expiration_days = 730
  tags = {
    Environment = "shared"
    Owner       = "platform"
    CostCenter  = "replace-me"
  }
}
