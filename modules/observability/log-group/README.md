# CloudWatch log group

Creates one explicitly named CloudWatch log group with validated retention, optional
KMS encryption, and non-overridable Terraform ownership tags.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| terraform | >= 1.6.0 |
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
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| name | CloudWatch log group name (full path, e.g. /z2h/dev/apps). | `string` | n/a | yes |
| kms\_key\_id | Optional KMS key ARN for CloudWatch Logs encryption. Null uses the AWS-managed default. | `string` | `null` | no |
| retention\_days | Log retention in days. | `number` | `14` | no |
| tags | Tags to apply to the log group. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| arn | Log group ARN. |
| name | Log group name. |
<!-- END_TF_DOCS -->
