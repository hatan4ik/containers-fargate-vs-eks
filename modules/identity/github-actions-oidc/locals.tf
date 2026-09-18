locals {
  oidc_provider_arn = coalesce(var.github_oidc_provider_arn, try(aws_iam_openid_connect_provider.github[0].arn, null))

  required_tags = {
    ManagedBy = "terraform"
    Module    = "identity/github-actions-oidc"
    Name      = var.name
  }

  tags = merge(var.tags, local.required_tags)

  apply_policy_attachments = {
    for attachment in flatten([
      for environment_name, environment in var.environments : [
        for policy_arn in environment.apply_policy_arns : {
          key              = "${environment_name}-${sha1(policy_arn)}"
          environment_name = environment_name
          policy_arn       = policy_arn
        }
      ]
    ]) : attachment.key => attachment
  }
}
