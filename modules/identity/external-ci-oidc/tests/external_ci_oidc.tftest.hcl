provider "aws" {
  region                      = "us-east-1"
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true
}

run "exact_subject_roles_plan" {
  command = plan

  variables {
    name            = "example-gitlab-ci"
    issuer_url      = "https://gitlab.com"
    audience        = "sts.amazonaws.com"
    thumbprint_list = ["aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"]
    roles = {
      fargate-dev-plan = {
        subject     = "project_path:example-group/example-project:environment:fargate-dev"
        policy_arns = ["arn:aws:iam::000000000000:policy/terraform-fargate-dev-plan"]
      }
    }
  }

  assert {
    condition     = contains(keys(output.role_arns), "fargate-dev-plan")
    error_message = "expected an OIDC role keyed by the stable role name"
  }
}

run "invalid_thumbprint_rejected" {
  command = plan

  variables {
    name            = "example-gitlab-ci"
    issuer_url      = "https://gitlab.com"
    audience        = "sts.amazonaws.com"
    thumbprint_list = ["not-a-thumbprint"]
    roles = {
      fargate-dev-plan = {
        subject     = "project_path:example-group/example-project:environment:fargate-dev"
        policy_arns = ["arn:aws:iam::000000000000:policy/terraform-fargate-dev-plan"]
      }
    }
  }

  expect_failures = [var.thumbprint_list]
}
