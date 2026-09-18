provider "aws" {
  region                      = "us-east-1"
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true
}

run "minimal_topology_plan" {
  command = plan

  variables {
    name                = "example-dev"
    region              = "us-east-1"
    vpc_cidr            = "10.40.0.0/16"
    availability_zones  = ["us-east-1a", "us-east-1b"]
    allow_insecure_http = true
    services = {
      gateway = { image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/gateway@sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" }
      orders  = { image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/orders@sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" }
      users   = { image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/users@sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" }
    }
  }

  assert {
    condition     = output.cluster_name == "example-dev-cluster"
    error_message = "unexpected ECS cluster name"
  }
}
