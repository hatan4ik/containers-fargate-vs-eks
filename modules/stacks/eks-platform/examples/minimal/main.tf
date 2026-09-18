terraform {
  required_version = ">= 1.6.0, < 2.0.0"
}

provider "aws" {
  region = "us-east-1"
}

module "platform" {
  source = "../.."

  name               = "example-dev"
  vpc_cidr           = "10.50.0.0/16"
  availability_zones = ["us-east-1a", "us-east-1b"]
}
