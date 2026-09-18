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
    name               = "test-eks"
    public_subnet_ids  = ["subnet-00000000000000001", "subnet-00000000000000002"]
    private_subnet_ids = ["subnet-00000000000000003", "subnet-00000000000000004"]
  }

  assert {
    condition     = output.cluster_name == "test-eks-eks"
    error_message = "unexpected EKS cluster name"
  }
}

run "public_endpoint_requires_cidrs" {
  command = plan

  variables {
    name                         = "test-eks"
    public_subnet_ids            = ["subnet-00000000000000001", "subnet-00000000000000002"]
    private_subnet_ids           = ["subnet-00000000000000003", "subnet-00000000000000004"]
    endpoint_public_access       = true
    endpoint_public_access_cidrs = []
  }

  expect_failures = [aws_eks_cluster.this]
}

run "invalid_node_disk_rejected" {
  command = plan

  variables {
    name               = "test-eks"
    public_subnet_ids  = ["subnet-00000000000000001", "subnet-00000000000000002"]
    private_subnet_ids = ["subnet-00000000000000003", "subnet-00000000000000004"]
    node_disk_size_gb  = 10
  }

  expect_failures = [var.node_disk_size_gb]
}
