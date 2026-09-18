# External CI OIDC bootstrap

Creates a distinct IAM OIDC provider and exact-subject role set for GitLab or
Azure DevOps. Run it only after `bootstrap/state-backend` has created protected
remote state. It never creates static IAM users or access keys.

1. Copy `terraform.tfvars.example` to ignored `terraform.tfvars` and replace all
   identity-provider, role-policy, and thumbprint placeholders.
2. Copy `backend.hcl.example` outside the repository and initialize the secure
   state backend.
3. Run `terraform plan` using a human MFA/SSO session. Apply only after the AWS
   trust policy subject exactly matches the CI service connection/project.

`oidc_providers` is map-driven: adding another CI role is one new stable entry in
`terraform.tfvars`, not a copied IAM resource block.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.10.0, < 2.0.0 |
| aws | ~> 6.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| provider | ../../modules/identity/external-ci-oidc | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Lowercase prefix for external CI OIDC providers and roles. | `string` | n/a | yes |
| oidc\_providers | External CI issuers and their exact-subject IAM roles. Use one map entry per issuer, such as gitlab or azure-devops. | ```map(object({ issuer_url = string audience = string thumbprint_list = list(string) roles = map(object({ subject = string policy_arns = set(string) additional_string_equals = optional(map(set(string)), {}) })) }))``` | n/a | yes |
| region | AWS region used by the provider while provisioning account-level IAM resources. | `string` | n/a | yes |
| tags | Additional governance tags. Required bootstrap tags take precedence. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| oidc\_provider\_arns | OIDC provider ARNs keyed by external CI platform. |
| role\_arns | External CI role ARNs keyed first by platform and then stable role key. |
<!-- END_TF_DOCS -->
