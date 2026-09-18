provider "aws" {
  region                      = "us-east-1"
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true
}

run "private_endpoint_plan" {
  command = plan

  variables {
    name                = "test-eks"
    public_subnet_ids   = ["subnet-00000000000000001", "subnet-00000000000000002"]
    private_subnet_ids  = ["subnet-00000000000000003", "subnet-00000000000000004"]
    secrets_kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/11111111-1111-1111-1111-111111111111"
  }

  assert {
    condition     = output.cluster_name == "test-eks-eks"
    error_message = "unexpected EKS cluster name"
  }
}

run "invalid_secrets_key_rejected" {
  command = plan

  variables {
    name                = "test-eks"
    public_subnet_ids   = ["subnet-00000000000000001", "subnet-00000000000000002"]
    private_subnet_ids  = ["subnet-00000000000000003", "subnet-00000000000000004"]
    secrets_kms_key_arn = "not-a-kms-key"
  }

  expect_failures = [var.secrets_kms_key_arn]
}

run "invalid_node_disk_rejected" {
  command = plan

  variables {
    name                = "test-eks"
    public_subnet_ids   = ["subnet-00000000000000001", "subnet-00000000000000002"]
    private_subnet_ids  = ["subnet-00000000000000003", "subnet-00000000000000004"]
    node_disk_size_gb   = 10
    secrets_kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/11111111-1111-1111-1111-111111111111"
  }

  expect_failures = [var.node_disk_size_gb]
}
