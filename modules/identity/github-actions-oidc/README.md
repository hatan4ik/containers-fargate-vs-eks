# GitHub Actions OIDC roles

Creates one read-only planning role and one workload-policy-backed apply role per
stable environment key. Trust is restricted to the selected GitHub repository and
GitHub Environment. The caller must supply at least one reviewed least-privilege
apply policy for each environment; this module never grants administrator access.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| terraform | >= 1.6.0, < 2.0.0 |
| aws | ~> 6.0 |

## Providers

| Name | Version |
| ---- | ------- |
| aws | 6.65.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_iam_openid_connect_provider.github](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_role.apply](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.plan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.apply_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.plan_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.apply_workload](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.plan_read_only](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.apply_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.github_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.plan_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| environments | Stable environment keys with GitHub Environment names, dedicated state keys, and explicitly approved apply policies. | ```map(object({ github_environment = string state_key = string apply_policy_arns = set(string) }))``` | n/a | yes |
| github\_repository | GitHub repository allowed to request OIDC credentials, in owner/repository form. | `string` | n/a | yes |
| kms\_key\_arn | ARN of the KMS key encrypting Terraform state. | `string` | n/a | yes |
| name | Lowercase name prefix for IAM roles. | `string` | n/a | yes |
| state\_bucket\_arn | ARN of the Terraform state bucket. | `string` | n/a | yes |
| github\_oidc\_provider\_arn | Existing GitHub Actions OIDC provider ARN. Set to null to create it in this AWS account. | `string` | `null` | no |
| tags | Additional tags. Required module tags take precedence. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| apply\_role\_arns | Map of environment key to GitHub OIDC apply-role ARN. |
| github\_oidc\_provider\_arn | GitHub Actions OIDC provider ARN used by the roles. |
| plan\_role\_arns | Map of environment key to GitHub OIDC plan-role ARN. |
<!-- END_TF_DOCS -->
