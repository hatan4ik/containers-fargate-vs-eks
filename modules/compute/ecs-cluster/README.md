# ECS cluster and ingress

Creates an ECS cluster, Cloud Map namespace, task roles, ALB, and gateway target
group. TLS is caller-owned: pass an already validated ACM certificate ARN. HTTP-only
or world-open ingress require explicit, reviewable opt-ins.

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
| [aws_ecs_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_iam_role.task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.task_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.task_ecs_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.task_exec_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lb.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_security_group.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_service_discovery_private_dns_namespace.ns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_private_dns_namespace) | resource |
| [aws_vpc_security_group_egress_rule.alb_to_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.alb_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_wafv2_web_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl) | resource |
| [aws_wafv2_web_acl_association.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_association) | resource |
| [aws_wafv2_web_acl_logging_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_logging_configuration) | resource |
| [aws_iam_policy_document.ecs_task_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.task_ecs_exec](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| alb\_access\_logs | Pre-provisioned S3 bucket and prefix for ALB access logs. The bucket policy must allow the ALB log-delivery service for this account and region. | ```object({ bucket = string prefix = optional(string, "alb") })``` | n/a | yes |
| certificate\_arn | ACM certificate ARN for the mandatory TLS listener on the ALB. | `string` | n/a | yes |
| name | Name prefix for all resources in this module. | `string` | n/a | yes |
| public\_subnet\_ids | Public subnet IDs for the ALB. | `list(string)` | n/a | yes |
| vpc\_cidr | VPC CIDR block — used to scope security group egress rules. | `string` | n/a | yes |
| vpc\_id | VPC ID where the cluster and ALB are deployed. | `string` | n/a | yes |
| waf\_log\_destination\_arn | Kinesis Data Firehose delivery stream ARN for WAF logs. AWS requires its delivery stream name to begin aws-waf-logs-. | `string` | n/a | yes |
| alb\_ingress\_cidrs | CIDRs permitted to reach the ALB. Empty creates no public listener ingress. | `set(string)` | `[]` | no |
| allow\_public\_ingress | Explicitly permit 0.0.0.0/0 ALB ingress. Keep false unless a public internet-facing endpoint is required. | `bool` | `false` | no |
| container\_insights | Enable ECS Container Insights on the cluster. | `bool` | `true` | no |
| enable\_deletion\_protection | Protect the ALB from accidental deletion. Keep true in every persistent environment. | `bool` | `true` | no |
| tags | Additional tags merged onto every resource. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| acm\_certificate\_arn | ACM certificate ARN used by the mandatory HTTPS listener. |
| alb\_arn | ALB ARN. |
| alb\_dns\_name | ALB DNS name. |
| alb\_sg\_id | ALB security group ID. |
| alb\_zone\_id | ALB hosted zone ID (for Route 53 alias records). |
| cluster\_id | ECS cluster ID. |
| cluster\_name | ECS cluster name. |
| gateway\_target\_group\_arn | Target group ARN for the gateway service. |
| https\_listener\_arn | Mandatory HTTPS listener ARN. |
| service\_discovery\_namespace\_id | Cloud Map private DNS namespace ID. |
| service\_discovery\_namespace\_name | Cloud Map private DNS namespace name (e.g. z2h-dev.local). |
| task\_execution\_role\_arn | ECS task execution IAM role ARN (shared by all services). |
| task\_role\_arn | ECS task IAM role ARN (shared by all services). |
<!-- END_TF_DOCS -->
