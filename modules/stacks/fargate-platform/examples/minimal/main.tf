terraform {
  required_version = ">= 1.6.0, < 2.0.0"
}

provider "aws" {
  region = "us-east-1"
}

module "platform" {
  source = "../.."

  name                = "example-dev"
  region              = "us-east-1"
  vpc_cidr            = "10.40.0.0/16"
  availability_zones  = ["us-east-1a", "us-east-1b"]
  allow_insecure_http = true
  services = {
    gateway = { image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/gateway@sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" }
    orders  = { image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/orders@sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" }
    users   = { image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/users@sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" }
  }
}
