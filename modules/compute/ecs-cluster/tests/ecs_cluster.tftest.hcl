provider "aws" {
  region                      = "us-east-1"
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true
}

run "tls_listener_plan" {
  command = plan
  variables {
    name              = "test-cluster"
    vpc_id            = "vpc-00000000000000001"
    vpc_cidr          = "10.0.0.0/16"
    public_subnet_ids = ["subnet-00000000000000001", "subnet-00000000000000002"]
    certificate_arn   = "arn:aws:acm:us-east-1:123456789012:certificate/11111111-1111-1111-1111-111111111111"
    alb_access_logs = {
      bucket = "example-alb-access-logs"
    }
  }

  assert {
    condition     = output.cluster_name == "test-cluster-cluster"
    error_message = "unexpected cluster name"
  }

  assert {
    condition     = output.acm_certificate_arn == "arn:aws:acm:us-east-1:123456789012:certificate/11111111-1111-1111-1111-111111111111"
    error_message = "the configured ACM certificate must be used"
  }
}

run "invalid_name_rejected" {
  command = plan
  variables {
    name              = "THIS_IS_INVALID"
    vpc_id            = "vpc-00000000000000001"
    vpc_cidr          = "10.0.0.0/16"
    public_subnet_ids = ["subnet-00000000000000001", "subnet-00000000000000002"]
    certificate_arn   = "arn:aws:acm:us-east-1:123456789012:certificate/11111111-1111-1111-1111-111111111111"
    alb_access_logs = {
      bucket = "example-alb-access-logs"
    }
  }

  expect_failures = [var.name]
}

run "invalid_cidr_rejected" {
  command = plan
  variables {
    name              = "test-cluster"
    vpc_id            = "vpc-00000000000000001"
    vpc_cidr          = "not-a-cidr"
    public_subnet_ids = ["subnet-00000000000000001", "subnet-00000000000000002"]
    certificate_arn   = "arn:aws:acm:us-east-1:123456789012:certificate/11111111-1111-1111-1111-111111111111"
    alb_access_logs = {
      bucket = "example-alb-access-logs"
    }
  }

  expect_failures = [var.vpc_cidr]
}
