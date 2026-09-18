# EKS cluster

Creates a private-by-default EKS cluster, managed node group, IRSA OIDC provider,
and core managed add-ons. Public API access is impossible without explicit CIDRs.
The OIDC thumbprint is derived from the cluster issuer certificate, never a static
placeholder.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| terraform | >= 1.6.0 |
| aws | ~> 6.0 |
| tls | ~> 4.0 |

## Providers

| Name | Version |
| ---- | ------- |
| aws | 6.65.0 |
| tls | 4.4.1 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_eks_addon.coredns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_eks_addon.kube_proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_eks_addon.vpc_cni](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster) | resource |
| [aws_eks_node_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group) | resource |
| [aws_iam_openid_connect_provider.oidc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_role.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.cluster_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.node_cni](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.node_ecr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.node_worker](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [tls_certificate.oidc](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/data-sources/certificate) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| name | Name prefix for all resources. | `string` | n/a | yes |
| private\_subnet\_ids | Private subnet IDs for node groups (tagged kubernetes.io/role/internal-elb=1). | `list(string)` | n/a | yes |
| public\_subnet\_ids | Public subnet IDs (tagged kubernetes.io/role/elb=1 by the vpc module). | `list(string)` | n/a | yes |
| secrets\_kms\_key\_arn | Dedicated customer-managed KMS key ARN for EKS Kubernetes Secret envelope encryption. Do not reuse the Terraform state key. | `string` | n/a | yes |
| kubernetes\_version | EKS Kubernetes version (e.g. "1.30"). | `string` | `"1.30"` | no |
| node\_disk\_size\_gb | Root EBS volume size in GiB for each node. | `number` | `50` | no |
| node\_instance\_type | EC2 instance type for the default node group. | `string` | `"t3.medium"` | no |
| node\_scaling | Node group scaling configuration. | ```object({ desired = optional(number, 2) min = optional(number, 2) max = optional(number, 5) })``` | `{}` | no |
| tags | Additional tags merged onto every resource. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| cluster\_certificate\_authority\_data | Base64 encoded EKS cluster certificate authority data. |
| cluster\_endpoint | EKS cluster API endpoint. |
| cluster\_name | EKS cluster name. |
| cluster\_oidc\_issuer\_url | OIDC issuer URL for IAM roles for service accounts. |
| cluster\_security\_group\_id | EKS-managed cluster security group ID. |
| node\_group\_name | Default managed node group name. |
| oidc\_provider\_arn | IAM OIDC provider ARN for IAM roles for service accounts. |
<!-- END_TF_DOCS -->
