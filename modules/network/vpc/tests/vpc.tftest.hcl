provider "aws" {
  region                      = "us-east-1"
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true
}

# ── Minimal config ────────────────────────────────────────────────────────────
run "minimal_config" {
  command = plan
  variables {
    name               = "test-vpc"
    cidr               = "10.200.0.0/16"
    availability_zones = ["us-east-1a", "us-east-1b"]
  }

  assert {
    condition     = output.flow_log_group_name == "/test-vpc/vpc-flow-logs"
    error_message = "unexpected derived flow-log group name"
  }

  assert {
    condition     = length(output.public_subnet_id_list) == 2
    error_message = "expected 2 public subnets"
  }

  assert {
    condition     = length(output.private_subnet_id_list) == 2
    error_message = "expected 2 private subnets"
  }
}

# ── Three AZs ─────────────────────────────────────────────────────────────────
run "three_az_config" {
  command = plan
  variables {
    name               = "test-vpc-3az"
    cidr               = "10.201.0.0/16"
    availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
    single_nat_gateway = true
  }

  assert {
    condition     = length(output.private_subnet_id_list) == 3
    error_message = "expected 3 private subnets"
  }
}

# ── Validation: bad CIDR ──────────────────────────────────────────────────────
run "invalid_cidr_rejected" {
  command = plan
  variables {
    name               = "test-vpc"
    cidr               = "not-a-cidr"
    availability_zones = ["us-east-1a", "us-east-1b"]
  }

  expect_failures = [var.cidr]
}

# ── Validation: too few AZs ───────────────────────────────────────────────────
run "too_few_azs_rejected" {
  command = plan
  variables {
    name               = "test-vpc"
    cidr               = "10.202.0.0/16"
    availability_zones = ["us-east-1a"]
  }

  expect_failures = [var.availability_zones]
}
