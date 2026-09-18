provider "aws" {
  region                      = "us-east-1"
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true
}

run "secure_state_plan" {
  command = plan

  variables {
    name        = "example-platform"
    bucket_name = "example-platform-terraform-state-unique"
  }

  assert {
    condition     = output.bucket_name == "example-platform-terraform-state-unique"
    error_message = "unexpected state bucket name"
  }
}

run "invalid_bucket_name_rejected" {
  command = plan

  variables {
    name        = "example-platform"
    bucket_name = "INVALID_BUCKET"
  }

  expect_failures = [var.bucket_name]
}
