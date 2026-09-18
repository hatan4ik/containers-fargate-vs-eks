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
    name                     = "example-platform"
    bucket_name              = "example-platform-terraform-state-unique"
    access_log_bucket_name   = "example-platform-audit-logs"
    replica_bucket_arn       = "arn:aws:s3:::example-platform-state-replica"
    replica_kms_key_arn      = "arn:aws:kms:us-west-2:123456789012:key/11111111-1111-1111-1111-111111111111"
    kms_key_account_root_arn = "arn:aws:iam::123456789012:root"
  }

  assert {
    condition     = output.bucket_name == "example-platform-terraform-state-unique"
    error_message = "unexpected state bucket name"
  }
}

run "invalid_bucket_name_rejected" {
  command = plan

  variables {
    name                     = "example-platform"
    bucket_name              = "INVALID_BUCKET"
    access_log_bucket_name   = "example-platform-audit-logs"
    replica_bucket_arn       = "arn:aws:s3:::example-platform-state-replica"
    replica_kms_key_arn      = "arn:aws:kms:us-west-2:123456789012:key/11111111-1111-1111-1111-111111111111"
    kms_key_account_root_arn = "arn:aws:iam::123456789012:root"
  }

  expect_failures = [var.bucket_name]
}
