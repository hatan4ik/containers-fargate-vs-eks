provider "aws" {
  region                      = "us-east-1"
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true
}

run "minimal_service" {
  command = plan
  variables {
    name                      = "test"
    service_name              = "users"
    region                    = "us-east-1"
    cluster_id                = "arn:aws:ecs:us-east-1:123456789012:cluster/test-cluster"
    cluster_name              = "test-cluster"
    vpc_id                    = "vpc-00000000000000001"
    vpc_cidr                  = "10.0.0.0/16"
    private_subnet_ids        = ["subnet-00000000000000001"]
    image                     = "123456789012.dkr.ecr.us-east-1.amazonaws.com/users:sha-aabbccddee1122334455667788990011aabbccdd"
    port                      = 3001
    log_group_name            = "/test/apps"
    task_execution_role_arn   = "arn:aws:iam::123456789012:role/test-ecs-task-exec"
    task_role_arn             = "arn:aws:iam::123456789012:role/test-ecs-task"
    ingress_security_group_id = "sg-00000000000000001"
  }

  assert {
    condition     = output.service_name == "test-users"
    error_message = "unexpected service name"
  }

  assert {
    condition     = output.service_discovery_arn == null
    error_message = "service_discovery_arn should be null when namespace not provided"
  }
}

run "invalid_image_rejected" {
  command = plan
  variables {
    name                      = "test"
    service_name              = "users"
    region                    = "us-east-1"
    cluster_id                = "arn:aws:ecs:us-east-1:123456789012:cluster/test-cluster"
    cluster_name              = "test-cluster"
    vpc_id                    = "vpc-00000000000000001"
    vpc_cidr                  = "10.0.0.0/16"
    private_subnet_ids        = ["subnet-00000000000000001"]
    image                     = "myimage:latest"
    port                      = 3001
    log_group_name            = "/test/apps"
    task_execution_role_arn   = "arn:aws:iam::123456789012:role/test-ecs-task-exec"
    task_role_arn             = "arn:aws:iam::123456789012:role/test-ecs-task"
    ingress_security_group_id = "sg-00000000000000001"
  }

  expect_failures = [var.image]
}

run "invalid_log_level_rejected" {
  command = plan
  variables {
    name                      = "test"
    service_name              = "users"
    region                    = "us-east-1"
    cluster_id                = "arn:aws:ecs:us-east-1:123456789012:cluster/test-cluster"
    cluster_name              = "test-cluster"
    vpc_id                    = "vpc-00000000000000001"
    vpc_cidr                  = "10.0.0.0/16"
    private_subnet_ids        = ["subnet-00000000000000001"]
    image                     = "123456789012.dkr.ecr.us-east-1.amazonaws.com/users:sha-aabbccddee1122334455667788990011aabbccdd"
    port                      = 3001
    log_group_name            = "/test/apps"
    task_execution_role_arn   = "arn:aws:iam::123456789012:role/test-ecs-task-exec"
    task_role_arn             = "arn:aws:iam::123456789012:role/test-ecs-task"
    ingress_security_group_id = "sg-00000000000000001"
    log_level                 = "verbose"
  }

  expect_failures = [var.log_level]
}
