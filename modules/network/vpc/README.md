# VPC

Creates a DNS-enabled VPC with stable AZ-keyed subnets, routing, optional single
NAT topology, and VPC flow logs. Explicit availability-zone names prevent resource
index shifts. Optional legacy flow-log names support a plan-verified state migration.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6.0 |
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
| [aws_cloudwatch_log_group.vpc_flow](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_default_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_eip.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_flow_log.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log) | resource |
| [aws_iam_role.flow_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.flow_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_internet_gateway.igw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route.private_nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.public_internet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_iam_policy_document.flow_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.flow_logs_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| availability\_zones | Explicit list of AZ names to use (e.g. ["us-east-1a","us-east-1b"]). Length must be 2 or 3. | `list(string)` | n/a | yes |
| cidr | IPv4 CIDR block for the VPC (e.g. 10.40.0.0/16). | `string` | n/a | yes |
| flow\_log\_kms\_key\_id | Customer-managed KMS key ARN used to encrypt VPC flow logs. Use a key policy that permits the regional CloudWatch Logs service. | `string` | n/a | yes |
| name | Name prefix applied to every resource in this module. | `string` | n/a | yes |
| eks\_subnet\_tags | When true, add kubernetes.io/role/elb and kubernetes.io/role/internal-elb tags to subnets (required for EKS load-balancer controllers). | `bool` | `false` | no |
| flow\_log\_group\_name | Existing-compatible VPC flow-log group name. Null derives /<name>/vpc-flow-logs. | `string` | `null` | no |
| flow\_log\_retention\_days | CloudWatch log retention in days for VPC flow logs. | `number` | `365` | no |
| flow\_log\_role\_name | Existing-compatible VPC flow-log IAM role name. Null derives <name>-vpc-flow-logs. | `string` | `null` | no |
| single\_nat\_gateway | Use one NAT gateway (cost saving) instead of one per AZ (fault tolerant). | `bool` | `false` | no |
| tags | Additional tags merged onto every resource. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| flow\_log\_group\_name | Name of the VPC flow log CloudWatch log group. |
| flow\_log\_role\_name | Name of the IAM role used by VPC flow logs. |
| private\_subnet\_id\_list | Ordered list of private subnet IDs (sorted by AZ name). |
| private\_subnet\_ids | Map of AZ name → private subnet ID. |
| public\_subnet\_id\_list | Ordered list of public subnet IDs (sorted by AZ name). |
| public\_subnet\_ids | Map of AZ name → public subnet ID. |
| vpc\_cidr | CIDR block of the VPC. |
| vpc\_id | ID of the VPC. |
<!-- END_TF_DOCS -->
