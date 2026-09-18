provider "aws" {
  region                      = "us-east-1"
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true
}

run "minimal_http_only" {
  command = plan
  variables {
    name                = "test-cluster"
    vpc_id              = "vpc-00000000000000001"
    vpc_cidr            = "10.0.0.0/16"
    public_subnet_ids   = ["subnet-00000000000000001", "subnet-00000000000000002"]
    allow_insecure_http = true
  }

  assert {
    condition     = output.cluster_name == "test-cluster-cluster"
    error_message = "unexpected cluster name"
  }

  assert {
    condition     = output.https_listener_arn == null
    error_message = "https listener should be null when no cert is provided"
  }

  assert {
    condition     = output.acm_certificate_arn == null
    error_message = "acm_certificate_arn should be null in HTTP-only mode"
  }
}

run "invalid_name_rejected" {
  command = plan
  variables {
    name                = "THIS_IS_INVALID"
    vpc_id              = "vpc-00000000000000001"
    vpc_cidr            = "10.0.0.0/16"
    public_subnet_ids   = ["subnet-00000000000000001", "subnet-00000000000000002"]
    allow_insecure_http = true
  }

  expect_failures = [var.name]
}

run "invalid_cidr_rejected" {
  command = plan
  variables {
    name                = "test-cluster"
    vpc_id              = "vpc-00000000000000001"
    vpc_cidr            = "not-a-cidr"
    public_subnet_ids   = ["subnet-00000000000000001", "subnet-00000000000000002"]
    allow_insecure_http = true
  }

  expect_failures = [var.vpc_cidr]
}
