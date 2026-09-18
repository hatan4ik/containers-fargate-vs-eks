terraform {
  required_version = ">= 1.6.0, < 2.0.0"
}

provider "aws" {
  region = "us-east-1"
}

module "ecs_service" {
  source = "../.."

  name                      = "example-dev"
  service_name              = "users"
  region                    = "us-east-1"
  cluster_id                = "arn:aws:ecs:us-east-1:123456789012:cluster/example-dev-cluster"
  cluster_name              = "example-dev-cluster"
  vpc_id                    = "vpc-replace"
  vpc_cidr                  = "10.40.0.0/16"
  private_subnet_ids        = ["subnet-replace"]
  image                     = "123456789012.dkr.ecr.us-east-1.amazonaws.com/users@sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  port                      = 3001
  log_group_name            = "/example-dev/apps"
  task_execution_role_arn   = "arn:aws:iam::123456789012:role/example-dev-ecs-task-exec"
  task_role_arn             = "arn:aws:iam::123456789012:role/example-dev-ecs-task"
  ingress_security_group_id = "sg-replace"
}
