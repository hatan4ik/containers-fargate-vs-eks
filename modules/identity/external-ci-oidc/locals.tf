locals {
  issuer_claim_namespace = trimprefix(var.issuer_url, "https://")

  required_tags = {
    ManagedBy = "terraform"
    Module    = "identity/external-ci-oidc"
    Name      = var.name
  }

  tags = merge(var.tags, local.required_tags)

  role_conditions = {
    for role_key, role in var.roles : role_key => merge(
      role.additional_string_equals,
      {
        "${local.issuer_claim_namespace}:aud" = toset([var.audience])
        "${local.issuer_claim_namespace}:sub" = toset([role.subject])
      },
    )
  }

  policy_attachments = {
    for attachment in flatten([
      for role_key, role in var.roles : [
        for policy_arn in role.policy_arns : {
          key        = "${role_key}-${sha1(policy_arn)}"
          role_key   = role_key
          policy_arn = policy_arn
        }
      ]
    ]) : attachment.key => attachment
  }
}
