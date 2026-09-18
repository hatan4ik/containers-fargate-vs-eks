locals {
  required_tags = {
    ManagedBy = "terraform"
    Project   = "containers-fargate-vs-eks"
    Component = "state-backend"
  }

  tags = merge(var.tags, local.required_tags)

  environments = {
    fargate-dev = {
      github_environment = "fargate-dev"
      state_key          = "containers-fargate-vs-eks/fargate/dev/terraform.tfstate"
      apply_policy_arns  = var.apply_policy_arns["fargate-dev"]
    }
    fargate-prod = {
      github_environment = "fargate-prod"
      state_key          = "containers-fargate-vs-eks/fargate/prod/terraform.tfstate"
      apply_policy_arns  = var.apply_policy_arns["fargate-prod"]
    }
    eks-dev = {
      github_environment = "eks-dev"
      state_key          = "containers-fargate-vs-eks/eks/dev/terraform.tfstate"
      apply_policy_arns  = var.apply_policy_arns["eks-dev"]
    }
    eks-prod = {
      github_environment = "eks-prod"
      state_key          = "containers-fargate-vs-eks/eks/prod/terraform.tfstate"
      apply_policy_arns  = var.apply_policy_arns["eks-prod"]
    }
  }
}
