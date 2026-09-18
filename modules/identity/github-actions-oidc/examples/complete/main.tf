terraform {
  required_version = ">= 1.6.0, < 2.0.0"
}

provider "aws" {
  region = "us-east-1"
}

module "github_actions_oidc" {
  source = "../.."

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
    fargate-prod = {
      github_environment = "fargate-prod"
      state_key          = "containers-fargate-vs-eks/fargate/prod/terraform.tfstate"
      apply_policy_arns  = ["arn:aws:iam::123456789012:policy/terraform-fargate-prod-apply"]
    }
  }
  tags = {
    Owner      = "platform"
    CostCenter = "replace-me"
  }
}
