# EKS platform

Composes the VPC, EKS control-plane log group, private-by-default EKS cluster,
managed node group, and IRSA OIDC provider. An environment configures all of it
through one typed module call.

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
| cluster\_logs | ../../observability/log-group | n/a |
| eks | ../../compute/eks | n/a |
| vpc | ../../network/vpc | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| availability\_zones | Two or three explicit availability-zone names used by the VPC. | `list(string)` | n/a | yes |
| cluster\_log\_kms\_key\_id | Customer-managed KMS key ARN used to encrypt EKS control-plane logs. | `string` | n/a | yes |
| flow\_log\_kms\_key\_id | Customer-managed KMS key ARN used to encrypt VPC flow logs. | `string` | n/a | yes |
| name | Stable resource-name prefix, normally <organization>-<environment>-<region>. | `string` | n/a | yes |
| secrets\_kms\_key\_arn | Dedicated customer-managed KMS key ARN for Kubernetes Secret envelope encryption. | `string` | n/a | yes |
| vpc\_cidr | IPv4 CIDR block for the EKS VPC. | `string` | n/a | yes |
| cluster\_log\_retention\_days | EKS control-plane log retention in days. | `number` | `365` | no |
| flow\_log\_group\_name | Optional compatibility name for the VPC flow-log group. Null derives a canonical name. | `string` | `null` | no |
| flow\_log\_retention\_days | VPC flow-log retention in days. | `number` | `365` | no |
| flow\_log\_role\_name | Optional compatibility name for the VPC flow-log role. Null derives a canonical name. | `string` | `null` | no |
| kubernetes\_version | EKS Kubernetes version. | `string` | `"1.30"` | no |
| node\_disk\_size\_gb | Root disk size for the default EKS managed node group. | `number` | `50` | no |
| node\_instance\_type | EC2 instance type for the default EKS managed node group. | `string` | `"t3.medium"` | no |
| node\_scaling | Default EKS managed node group capacity. | ```object({ desired = optional(number, 2) min = optional(number, 2) max = optional(number, 5) })``` | `{}` | no |
| single\_nat\_gateway | Use one NAT gateway for a cost-optimized non-production topology. | `bool` | `false` | no |
| tags | Additional tags. Required module tags take precedence. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| cluster\_endpoint | EKS Kubernetes API endpoint. |
| cluster\_name | EKS cluster name. |
| oidc\_provider\_arn | IAM OIDC provider ARN for IAM roles for service accounts. |
| vpc\_id | Workload VPC ID. |
<!-- END_TF_DOCS -->
