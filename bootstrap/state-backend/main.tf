module "terraform_state" {
  source = "../../modules/platform/terraform-state"

  name                     = var.name
  bucket_name              = var.state_bucket_name
  access_log_bucket_name   = var.access_log_bucket_name
  replica_bucket_arn       = var.replica_bucket_arn
  replica_kms_key_arn      = var.replica_kms_key_arn
  kms_key_account_root_arn = var.kms_key_account_root_arn
  tags                     = local.tags
}

module "github_actions_oidc" {
  source = "../../modules/identity/github-actions-oidc"

  name                     = var.name
  github_repository        = var.github_repository
  github_oidc_provider_arn = var.github_oidc_provider_arn
  state_bucket_arn         = module.terraform_state.bucket_arn
  kms_key_arn              = module.terraform_state.kms_key_arn
  environments             = local.environments
  tags                     = local.tags
}
