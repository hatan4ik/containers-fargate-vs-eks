terraform {
  required_version = ">= 1.6.0, < 2.0.0"
}

provider "aws" {
  region = "us-east-1"
}

module "ecs_cluster" {
  source = "../.."

  name                    = "example-prod"
  vpc_id                  = "vpc-replace"
  vpc_cidr                = "10.40.0.0/16"
  public_subnet_ids       = ["subnet-replace-1", "subnet-replace-2"]
  certificate_arn         = "arn:aws:acm:us-east-1:123456789012:certificate/replace-me"
  waf_log_destination_arn = "arn:aws:firehose:us-east-1:123456789012:deliverystream/aws-waf-logs-replace-me"
  alb_ingress_cidrs       = ["203.0.113.0/24"]
  container_insights      = true
  alb_access_logs = {
    bucket = "replace-with-alb-access-log-bucket"
  }
  tags = {
    Environment = "prod"
    Owner       = "platform"
  }
}
