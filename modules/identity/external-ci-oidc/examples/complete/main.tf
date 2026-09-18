terraform {
  required_version = ">= 1.10.0, < 2.0.0"
}

provider "aws" {
  region = "us-east-1"
}

module "gitlab_oidc" {
  source = "../.."

  name            = "example-gitlab-ci"
  issuer_url      = "https://gitlab.com"
  audience        = "sts.amazonaws.com"
  thumbprint_list = ["aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"]
  roles = {
    fargate-prod-plan = {
      subject     = "project_path:example-group/example-project:environment:fargate-prod"
      policy_arns = ["arn:aws:iam::000000000000:policy/terraform-fargate-prod-plan"]
      additional_string_equals = {
        "gitlab.com:project_id"   = ["12345678"]
        "gitlab.com:ref_protected" = ["true"]
      }
    }
  }
  tags = {
    Owner      = "platform"
    CostCenter = "example"
  }
}
