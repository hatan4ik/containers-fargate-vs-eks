# Terraform state backend

Creates a dedicated, recoverable Terraform state bucket: versioned, KMS-encrypted,
publicly blocked, TLS-only, and protected from accidental Terraform destruction.

State access and workload permissions are deliberately not granted here. Use the
`identity/github-actions-oidc` module to create narrow CI roles.

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
| [aws_iam_role.replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_kms_alias.state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_bucket.state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_logging.state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_notification.state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) | resource |
| [aws_s3_bucket_ownership_controls.state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_replication_configuration.state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_replication_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_iam_policy_document.replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.replication_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.state_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.state_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| access\_log\_bucket\_name | Dedicated pre-provisioned S3 bucket that receives state-bucket server access logs. Its bucket policy must allow S3 log delivery. | `string` | n/a | yes |
| bucket\_name | Globally unique S3 bucket name used exclusively for Terraform state. | `string` | n/a | yes |
| kms\_key\_account\_root\_arn | AWS account root principal ARN that enables IAM policies to administer and use the state KMS key. | `string` | n/a | yes |
| name | Lowercase name prefix used for the KMS alias and required tags. | `string` | n/a | yes |
| replica\_bucket\_arn | Versioned, cross-region S3 bucket ARN that receives replicated state objects. | `string` | n/a | yes |
| replica\_kms\_key\_arn | Customer-managed KMS key ARN in the replica region. Its key policy must allow the source replication role to encrypt objects. | `string` | n/a | yes |
| access\_log\_prefix | Prefix used for S3 server access logs in access\_log\_bucket\_name. | `string` | `"terraform-state"` | no |
| noncurrent\_version\_expiration\_days | Number of days to retain non-current state versions for recovery. Current state is never expired. | `number` | `365` | no |
| tags | Additional tags. Required module tags take precedence. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| bucket\_arn | Terraform state bucket ARN. |
| bucket\_name | Terraform state bucket name. |
| kms\_key\_arn | KMS key ARN used to encrypt Terraform state and lock files. |
| kms\_key\_id | KMS key ID for partial S3 backend configuration. |
<!-- END_TF_DOCS -->
