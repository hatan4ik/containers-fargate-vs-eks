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
    fargate-dev-plan = {
      subject     = "project_path:example-group/example-project:ref_type:branch:ref:main"
      policy_arns = ["arn:aws:iam::000000000000:policy/terraform-fargate-dev-plan"]
    }
  }
}
