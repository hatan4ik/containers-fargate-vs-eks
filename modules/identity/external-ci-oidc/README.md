<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.10.0, < 2.0.0 |
| aws | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| aws | 6.65.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_openid_connect_provider.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.workload](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| audience | OIDC audience accepted by AWS for this issuer. | `string` | n/a | yes |
| issuer\_url | Public HTTPS OIDC issuer URL, without a trailing slash. | `string` | n/a | yes |
| name | Lowercase prefix for the OIDC provider's IAM roles. | `string` | n/a | yes |
| roles | Stable role keys, exact OIDC subjects, least-privilege policy ARNs, and optional issuer-specific exact claim constraints. | ```map(object({ subject = string policy_arns = set(string) additional_string_equals = optional(map(set(string)), {}) }))``` | n/a | yes |
| thumbprint\_list | One or more SHA-1 TLS certificate thumbprints for the issuer, verified before apply. | `list(string)` | n/a | yes |
| tags | Additional tags. Required module tags take precedence. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| oidc\_provider\_arn | ARN of the OIDC provider created for this CI platform. |
| role\_arns | IAM role ARNs keyed by the stable role key. |
<!-- END_TF_DOCS -->