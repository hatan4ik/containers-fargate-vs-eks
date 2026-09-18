terraform {
  required_version = ">= 1.6.0, < 2.0.0"
}

provider "aws" {
  region = "us-east-1"
}

module "ecs_service" {
  source = "../.."

  name                           = "example-prod"
  service_name                   = "gateway"
  region                         = "us-east-1"
  cluster_id                     = "arn:aws:ecs:us-east-1:123456789012:cluster/example-prod-cluster"
  cluster_name                   = "example-prod-cluster"
  vpc_id                         = "vpc-replace"
  vpc_cidr                       = "10.40.0.0/16"
  private_subnet_ids             = ["subnet-replace-1", "subnet-replace-2"]
  image                          = "123456789012.dkr.ecr.us-east-1.amazonaws.com/gateway@sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  port                           = 3000
  cpu                            = 512
  memory                         = 1024
  desired_count                  = 2
  log_group_name                 = "/example-prod/apps"
  task_execution_role_arn        = "arn:aws:iam::123456789012:role/example-prod-ecs-task-exec"
  task_role_arn                  = "arn:aws:iam::123456789012:role/example-prod-ecs-task"
  ingress_security_group_id      = "sg-replace"
  service_discovery_namespace_id = "ns-replace"
  load_balancer = {
    target_group_arn = "arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/example/replace"
    container_port   = 3000
  }
  egress_rules = [{
    description      = "orders"
    from_port        = 3002
    to_port          = 3002
    ip_protocol      = "tcp"
    referenced_sg_id = "sg-orders"
  }]
  autoscaling = {
    min_capacity = 2
    max_capacity = 6
    cpu_target   = 60
  }
  tags = {
    Environment = "prod"
    Owner       = "platform"
  }
}
