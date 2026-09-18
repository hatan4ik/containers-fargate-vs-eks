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
| kms\_key\_id | Customer-managed KMS key ARN for CloudWatch Logs encryption. The key policy must permit the regional CloudWatch Logs service. | `string` | n/a | yes |
| name | CloudWatch log group name (full path, e.g. /z2h/dev/apps). | `string` | n/a | yes |
| retention\_days | Log retention in days. | `number` | `365` | no |
| tags | Tags to apply to the log group. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| arn | Log group ARN. |
| name | Log group name. |
<!-- END_TF_DOCS -->
