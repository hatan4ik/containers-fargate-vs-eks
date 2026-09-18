# Fargate application platform

Composes the VPC, application log group, ECS cluster, ALB, Cloud Map namespace,
and gateway → orders → users Fargate topology. Environments configure it through
one typed input object; all submodules remain independently reusable.

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
| application\_logs | ../../observability/log-group | n/a |
| cluster | ../../compute/ecs-cluster | n/a |
| gateway | ../../compute/ecs-service | n/a |
| orders | ../../compute/ecs-service | n/a |
| users | ../../compute/ecs-service | n/a |
| vpc | ../../network/vpc | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| alb\_access\_logs | Pre-provisioned S3 destination for ALB access logs. | ```object({ bucket = string prefix = optional(string, "alb") })``` | n/a | yes |
| application\_log\_kms\_key\_id | Customer-managed KMS key ARN used to encrypt application logs. | `string` | n/a | yes |
| availability\_zones | Two or three explicit availability-zone names used by the VPC. | `list(string)` | n/a | yes |
| certificate\_arn | Validated ACM certificate ARN for the mandatory ALB HTTPS listener. | `string` | n/a | yes |
| flow\_log\_kms\_key\_id | Customer-managed KMS key ARN used to encrypt VPC flow logs. | `string` | n/a | yes |
| name | Stable resource-name prefix, normally <organization>-<environment>-<region>. | `string` | n/a | yes |
| region | AWS region passed to Fargate task log configuration. | `string` | n/a | yes |
| services | Immutable images and per-service capacity/egress configuration for the gateway, orders, and users topology. | ```object({ gateway = object({ image = string desired_count = optional(number, 2) autoscaling = optional(object({ min_capacity = number max_capacity = number cpu_target = optional(number, 50) scale_in_cooldown = optional(number, 60) scale_out_cooldown = optional(number, 60) })) extra_egress_rules = optional(list(object({ description = string from_port = number to_port = number ip_protocol = string cidr_ipv4 = optional(string) referenced_sg_id = optional(string) })), []) }) orders = object({ image = string desired_count = optional(number, 2) autoscaling = optional(object({ min_capacity = number max_capacity = number cpu_target = optional(number, 50) scale_in_cooldown = optional(number, 60) scale_out_cooldown = optional(number, 60) })) extra_egress_rules = optional(list(object({ description = string from_port = number to_port = number ip_protocol = string cidr_ipv4 = optional(string) referenced_sg_id = optional(string) })), []) }) users = object({ image = string desired_count = optional(number, 2) autoscaling = optional(object({ min_capacity = number max_capacity = number cpu_target = optional(number, 50) scale_in_cooldown = optional(number, 60) scale_out_cooldown = optional(number, 60) })) extra_egress_rules = optional(list(object({ description = string from_port = number to_port = number ip_protocol = string cidr_ipv4 = optional(string) referenced_sg_id = optional(string) })), []) }) })``` | n/a | yes |
| vpc\_cidr | IPv4 CIDR block for the workload VPC. | `string` | n/a | yes |
| alb\_ingress\_cidrs | CIDRs permitted to reach the application load balancer. | `set(string)` | `[]` | no |
| allow\_public\_https\_egress | Explicitly permit 0.0.0.0/0 HTTPS egress for every task. | `bool` | `false` | no |
| allow\_public\_ingress | Explicitly allow 0.0.0.0/0 ALB ingress. | `bool` | `false` | no |
| application\_log\_retention\_days | Application log retention in days. | `number` | `365` | no |
| enable\_deletion\_protection | Prevent accidental ALB deletion. | `bool` | `true` | no |
| flow\_log\_group\_name | Optional compatibility name for the VPC flow-log group. Null derives a canonical name. | `string` | `null` | no |
| flow\_log\_retention\_days | VPC flow-log retention in days. | `number` | `365` | no |
| flow\_log\_role\_name | Optional compatibility name for the VPC flow-log role. Null derives a canonical name. | `string` | `null` | no |
| https\_egress\_cidrs | CIDRs permitted for outbound HTTPS from every task. Prefer VPC endpoints and narrow CIDRs. | `set(string)` | `[]` | no |
| single\_nat\_gateway | Use one NAT gateway for a cost-optimized non-production topology. | `bool` | `false` | no |
| tags | Additional tags. Required module tags take precedence. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| alb\_dns\_name | Application load balancer DNS name. |
| cluster\_name | ECS cluster name. |
| service\_names | Stable ECS service names keyed by application component. |
| vpc\_id | Workload VPC ID. |
<!-- END_TF_DOCS -->
