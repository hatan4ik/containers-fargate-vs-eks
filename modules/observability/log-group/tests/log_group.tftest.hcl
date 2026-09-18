provider "aws" {
  region                      = "us-east-1"
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true
}

run "minimal_log_group" {
  command = plan

  variables {
    name = "/example-dev/apps"
  }

  assert {
    condition     = output.name == "/example-dev/apps"
    error_message = "unexpected log group name"
  }
}

run "invalid_retention_rejected" {
  command = plan

  variables {
    name           = "/example-dev/apps"
    retention_days = 2
  }

  expect_failures = [var.retention_days]
}
