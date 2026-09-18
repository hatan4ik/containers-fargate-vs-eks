provider "aws" {
  region                      = "us-east-1"
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true
}

run "environment_scoped_roles_plan" {
  command = plan

  variables {
    name                     = "example-platform"
    github_repository        = "hatan4ik/containers-fargate-vs-eks"
    github_oidc_provider_arn = "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"
    state_bucket_arn         = "arn:aws:s3:::example-platform-terraform-state"
    kms_key_arn              = "arn:aws:kms:us-east-1:123456789012:key/replace-me"
    environments = {
      fargate-dev = {
        github_environment = "fargate-dev"
        state_key          = "containers-fargate-vs-eks/fargate/dev/terraform.tfstate"
        apply_policy_arns  = ["arn:aws:iam::123456789012:policy/terraform-fargate-dev-apply"]
      }
    }
  }

  assert {
    condition     = length(output.plan_role_arns) == 1 && contains(keys(output.plan_role_arns), "fargate-dev")
    error_message = "expected one environment-scoped plan role"
  }
}

run "empty_apply_policies_rejected" {
  command = plan

  variables {
    name                     = "example-platform"
    github_repository        = "hatan4ik/containers-fargate-vs-eks"
    github_oidc_provider_arn = "arn:aws:iam::123456789012:oidc-provider/token.actions.githubusercontent.com"
    state_bucket_arn         = "arn:aws:s3:::example-platform-terraform-state"
    kms_key_arn              = "arn:aws:kms:us-east-1:123456789012:key/replace-me"
    environments = {
      fargate-dev = {
        github_environment = "fargate-dev"
        state_key          = "containers-fargate-vs-eks/fargate/dev/terraform.tfstate"
        apply_policy_arns  = []
      }
    }
  }

  expect_failures = [var.environments]
}
