provider "aws" {
  region                      = "us-east-1"
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true
}

run "private_eks_topology_plan" {
  command = plan

  variables {
    name                   = "example-dev"
    vpc_cidr               = "10.50.0.0/16"
    availability_zones     = ["us-east-1a", "us-east-1b"]
    flow_log_kms_key_id    = "arn:aws:kms:us-east-1:123456789012:key/11111111-1111-1111-1111-111111111111"
    cluster_log_kms_key_id = "arn:aws:kms:us-east-1:123456789012:key/22222222-2222-2222-2222-222222222222"
    secrets_kms_key_arn    = "arn:aws:kms:us-east-1:123456789012:key/33333333-3333-3333-3333-333333333333"
  }

  assert {
    condition     = output.cluster_name == "example-dev-eks"
    error_message = "unexpected EKS cluster name"
  }
}
