# State backend bootstrap

This is the only stack initially run with a human MFA/SSO session. It creates the
S3 state backend, its KMS key, and GitHub Actions OIDC plan/apply roles. It does
not grant administrator access and it has no workload resources.

1. Copy `terraform.tfvars.example` to an ignored `terraform.tfvars` and supply
   a globally unique bucket name plus approved environment-scoped apply policies.
2. Review `terraform plan`; run the one-time bootstrap only after review.
3. Copy `backend.hcl.example` outside the repository and run
   `terraform init -migrate-state -backend-config=/safe/path/backend.hcl`.
4. Configure the emitted plan-role ARN in each GitHub Environment. Do not enable
   apply roles until the matching workload state migration has a verified no-op plan.

The GitHub repository default is derived from this repository's origin:
`hatan4ik/containers-fargate-vs-eks`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| terraform | >= 1.6.0, < 2.0.0 |
| aws | ~> 6.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| github\_actions\_oidc | ../../modules/identity/github-actions-oidc | n/a |
| terraform\_state | ../../modules/platform/terraform-state | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| apply\_policy\_arns | Approved least-privilege workload policy ARNs keyed by fargate-dev, fargate-prod, eks-dev, and eks-prod. | `map(set(string))` | n/a | yes |
| name | Organization/project prefix for state and CI identity resources. | `string` | n/a | yes |
| region | AWS region containing the state bucket and KMS key. | `string` | n/a | yes |
| state\_bucket\_name | Globally unique S3 bucket name for Terraform state. | `string` | n/a | yes |
| github\_oidc\_provider\_arn | Existing GitHub Actions OIDC provider ARN, or null to create it. | `string` | `null` | no |
| github\_repository | GitHub repository allowed to receive OIDC credentials. | `string` | `"hatan4ik/containers-fargate-vs-eks"` | no |
| tags | Additional governance tags. Required bootstrap tags take precedence. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| apply\_role\_arns | Environment-keyed OIDC apply-role ARNs. Configure these only after migration verification. |
| plan\_role\_arns | Environment-keyed OIDC plan-role ARNs. Configure these as GitHub Environment variables. |
| state\_bucket\_name | Terraform state bucket name for CI backend configuration. |
| state\_kms\_key\_id | Terraform state KMS key ID for CI backend configuration. |
<!-- END_TF_DOCS -->
