module "provider" {
  source   = "../../modules/identity/external-ci-oidc"
  for_each = var.oidc_providers

  name            = "${var.name}-${each.key}"
  issuer_url      = each.value.issuer_url
  audience        = each.value.audience
  thumbprint_list = each.value.thumbprint_list
  roles           = each.value.roles
  tags            = local.tags
}
