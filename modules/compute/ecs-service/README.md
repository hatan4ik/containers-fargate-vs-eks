# ECS service

Creates one least-privilege ECS/Fargate service with a stable service name,
security group, task definition, optional discovery/ALB registration, and optional
CPU autoscaling. Images must be digest- or commit-SHA-pinned. Broad HTTPS egress
requires an explicit opt-in.

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
| [aws_appautoscaling_policy.cpu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_ecs_service.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_service_discovery_service.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_service) | resource |
| [aws_vpc_security_group_egress_rule.dns_tcp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.dns_udp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.extra](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.service_port](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster\_id | ECS cluster ID. | `string` | n/a | yes |
| cluster\_name | ECS cluster name (used to build the autoscaling resource\_id). | `string` | n/a | yes |
| image | Container image URI with immutable tag or digest. | `string` | n/a | yes |
| ingress\_security\_group\_id | Security group ID allowed to send traffic to this service's port. Typically the ALB SG (for gateway) or an upstream service SG. | `string` | n/a | yes |
| log\_group\_name | CloudWatch log group name for container logs. | `string` | n/a | yes |
| name | Name prefix (typically env name, e.g. z2h-dev). | `string` | n/a | yes |
| port | Container port the service listens on. | `number` | n/a | yes |
| private\_subnet\_ids | Private subnet IDs for the ECS service network configuration. | `list(string)` | n/a | yes |
| region | AWS region written to the awslogs task-definition configuration. | `string` | n/a | yes |
| service\_name | Short service identifier (e.g. gateway, orders, users). Used in resource names. | `string` | n/a | yes |
| task\_execution\_role\_arn | ECS task execution IAM role ARN. | `string` | n/a | yes |
| task\_role\_arn | ECS task IAM role ARN. | `string` | n/a | yes |
| vpc\_cidr | VPC CIDR — used to scope DNS egress rules. | `string` | n/a | yes |
| vpc\_id | VPC ID. | `string` | n/a | yes |
| allow\_public\_https\_egress | Explicitly permit 0.0.0.0/0 HTTPS egress when VPC endpoints or narrower routes are unavailable. | `bool` | `false` | no |
| autoscaling | CPU-based autoscaling configuration. When null, autoscaling is not configured. | ```object({ min_capacity = number max_capacity = number cpu_target = optional(number, 50) scale_in_cooldown = optional(number, 60) scale_out_cooldown = optional(number, 60) })``` | `null` | no |
| cpu | Fargate task CPU units (256, 512, 1024, 2048, 4096). | `number` | `256` | no |
| desired\_count | Desired number of running tasks. | `number` | `2` | no |
| egress\_rules | Additional egress rules beyond the standard DNS+HTTPS egress. Use cidr\_ipv4 or referenced\_sg\_id, not both. | ```list(object({ description = string from_port = number to_port = number ip_protocol = string cidr_ipv4 = optional(string) referenced_sg_id = optional(string) }))``` | `[]` | no |
| enable\_service\_discovery | Create and register a Cloud Map service. When true, service\_discovery\_namespace\_id is required. | `bool` | `false` | no |
| environment | Environment variables injected into the container (in addition to PORT and LOG\_LEVEL). | ```list(object({ name = string value = string }))``` | `[]` | no |
| health\_check\_grace\_period\_seconds | Seconds ECS waits before starting health checks after a task starts. Set >0 for ALB-attached services. | `number` | `0` | no |
| https\_egress\_cidrs | CIDRs permitted for HTTPS egress. Keep empty when VPC endpoints and explicit security-group rules provide required access. | `set(string)` | `[]` | no |
| load\_balancer | ALB target group wiring. Set only for the internet-facing service (gateway). | ```object({ target_group_arn = string container_port = number })``` | `null` | no |
| log\_level | LOG\_LEVEL environment variable value. | `string` | `"info"` | no |
| memory | Fargate task memory in MiB. | `number` | `512` | no |
| service\_discovery\_namespace\_id | Cloud Map namespace ID used when service discovery is enabled. | `string` | `null` | no |
| tags | Additional tags merged onto every resource. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| security\_group\_id | Security group ID for this service's tasks. |
| service\_discovery\_arn | Cloud Map service ARN. Null when service discovery is not configured. |
| service\_id | ECS service ID. |
| service\_name | ECS service name. |
| task\_definition\_arn | Active task definition ARN. |
<!-- END_TF_DOCS -->
