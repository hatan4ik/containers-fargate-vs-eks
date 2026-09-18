terraform {
  required_version = ">= 1.6.0, < 2.0.0"
}

provider "aws" {
  region = "us-east-1"
}

module "platform" {
  source = "../.."

  name                       = "example-dev"
  region                     = "us-east-1"
  vpc_cidr                   = "10.40.0.0/16"
  availability_zones         = ["us-east-1a", "us-east-1b"]
  certificate_arn            = "arn:aws:acm:us-east-1:123456789012:certificate/replace-me"
  flow_log_kms_key_id        = "arn:aws:kms:us-east-1:123456789012:key/replace-me"
  application_log_kms_key_id = "arn:aws:kms:us-east-1:123456789012:key/replace-me"
  alb_access_logs = {
    bucket = "replace-with-alb-access-log-bucket"
  }
  waf_log_destination_arn = "arn:aws:firehose:us-east-1:123456789012:deliverystream/aws-waf-logs-replace-me"
  services = {
    gateway = { image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/gateway@sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" }
    orders  = { image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/orders@sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" }
    users   = { image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/users@sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" }
  }
}
