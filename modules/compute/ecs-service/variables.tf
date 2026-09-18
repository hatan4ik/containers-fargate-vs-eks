variable "name" {
  type        = string
  description = "Name prefix (typically env name, e.g. z2h-dev)."

  validation {
    condition     = can(regex("^[a-z0-9-]{1,24}$", var.name))
    error_message = "name must be 1-24 lowercase alphanumeric characters or hyphens."
  }
}

variable "service_name" {
  type        = string
  description = "Short service identifier (e.g. gateway, orders, users). Used in resource names."

  validation {
    condition     = can(regex("^[a-z0-9-]{1,20}$", var.service_name))
    error_message = "service_name must be 1-20 lowercase alphanumeric characters or hyphens."
  }
}

variable "region" {
  type        = string
  description = "AWS region written to the awslogs task-definition configuration."
  nullable    = false

  validation {
    condition     = can(regex("^[a-z]{2}(-gov)?-[a-z]+-[0-9]$", var.region))
    error_message = "region must be a valid AWS region identifier."
  }
}

variable "cluster_id" {
  type        = string
  description = "ECS cluster ID."
  nullable    = false
}

variable "cluster_name" {
  type        = string
  description = "ECS cluster name (used to build the autoscaling resource_id)."
  nullable    = false
}

variable "vpc_id" {
  type        = string
  description = "VPC ID."
  nullable    = false
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR — used to scope DNS egress rules."

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr must be a valid CIDR block."
  }
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for the ECS service network configuration."

  validation {
    condition     = length(var.private_subnet_ids) >= 1
    error_message = "At least one private subnet is required."
  }
}

variable "image" {
  type        = string
  description = "Container image URI with immutable tag or digest."

  validation {
    condition     = can(regex("(@sha256:[0-9a-f]{64}|:sha-[0-9a-f]{40})$", var.image))
    error_message = "image must use an immutable digest (@sha256:...) or a sha-<40 hex> tag."
  }
}

variable "port" {
  type        = number
  description = "Container port the service listens on."

  validation {
    condition     = var.port >= 1 && var.port <= 65535
    error_message = "port must be between 1 and 65535."
  }
}

variable "cpu" {
  type        = number
  description = "Fargate task CPU units (256, 512, 1024, 2048, 4096)."
  default     = 256
  nullable    = false

  validation {
    condition     = contains([256, 512, 1024, 2048, 4096], var.cpu)
    error_message = "cpu must be one of: 256, 512, 1024, 2048, 4096."
  }
}

variable "memory" {
  type        = number
  description = "Fargate task memory in MiB."
  default     = 512
  nullable    = false

  validation {
    condition     = var.memory >= 512 && var.memory <= 30720
    error_message = "memory must be between 512 and 30720 MiB."
  }
}

variable "desired_count" {
  type        = number
  description = "Desired number of running tasks."
  default     = 2
  nullable    = false

  validation {
    condition     = var.desired_count >= 1
    error_message = "desired_count must be at least 1."
  }
}

variable "environment" {
  type = list(object({
    name  = string
    value = string
  }))
  description = "Environment variables injected into the container (in addition to PORT and LOG_LEVEL)."
  default     = []
  nullable    = false
}

variable "log_group_name" {
  type        = string
  description = "CloudWatch log group name for container logs."
  nullable    = false
}

variable "task_execution_role_arn" {
  type        = string
  description = "ECS task execution IAM role ARN."
  nullable    = false
}

variable "task_role_arn" {
  type        = string
  description = "ECS task IAM role ARN."
  nullable    = false
}

variable "ingress_security_group_id" {
  type        = string
  description = "Security group ID allowed to send traffic to this service's port. Typically the ALB SG (for gateway) or an upstream service SG."
  nullable    = false
}

variable "egress_rules" {
  type = list(object({
    description      = string
    from_port        = number
    to_port          = number
    ip_protocol      = string
    cidr_ipv4        = optional(string)
    referenced_sg_id = optional(string)
  }))
  description = "Additional egress rules beyond the standard DNS+HTTPS egress. Use cidr_ipv4 or referenced_sg_id, not both."
  default     = []
  nullable    = false

  validation {
    condition = length(distinct([for rule in var.egress_rules : rule.description])) == length(var.egress_rules) && alltrue([
      for rule in var.egress_rules :
      rule.from_port >= 0 && rule.to_port >= rule.from_port && rule.to_port <= 65535 &&
      contains(["tcp", "udp", "-1"], rule.ip_protocol) &&
      ((rule.cidr_ipv4 != null ? 1 : 0) + (rule.referenced_sg_id != null ? 1 : 0) == 1)
    ])
    error_message = "egress_rules need unique descriptions, valid ports/protocols, and exactly one of cidr_ipv4 or referenced_sg_id."
  }
}

variable "https_egress_cidrs" {
  type        = set(string)
  description = "CIDRs permitted for HTTPS egress. Keep empty when VPC endpoints and explicit security-group rules provide required access."
  default     = []
  nullable    = false

  validation {
    condition     = alltrue([for cidr in var.https_egress_cidrs : can(cidrnetmask(cidr))])
    error_message = "https_egress_cidrs must contain valid CIDR blocks."
  }
}

variable "allow_public_https_egress" {
  type        = bool
  description = "Explicitly permit 0.0.0.0/0 HTTPS egress when VPC endpoints or narrower routes are unavailable."
  default     = false
  nullable    = false
}

variable "service_discovery_namespace_id" {
  type        = string
  description = "Cloud Map namespace ID used when service discovery is enabled."
  default     = null
}

variable "enable_service_discovery" {
  type        = bool
  description = "Create and register a Cloud Map service. When true, service_discovery_namespace_id is required."
  default     = false
  nullable    = false
}

variable "load_balancer" {
  type = object({
    target_group_arn = string
    container_port   = number
  })
  description = "ALB target group wiring. Set only for the internet-facing service (gateway)."
  default     = null
}

variable "health_check_grace_period_seconds" {
  type        = number
  description = "Seconds ECS waits before starting health checks after a task starts. Set >0 for ALB-attached services."
  default     = 0
  nullable    = false

  validation {
    condition     = var.health_check_grace_period_seconds >= 0 && var.health_check_grace_period_seconds <= 2147483647
    error_message = "health_check_grace_period_seconds must be between 0 and 2147483647."
  }
}

variable "autoscaling" {
  type = object({
    min_capacity       = number
    max_capacity       = number
    cpu_target         = optional(number, 50)
    scale_in_cooldown  = optional(number, 60)
    scale_out_cooldown = optional(number, 60)
  })
  description = "CPU-based autoscaling configuration. When null, autoscaling is not configured."
  default     = null

  validation {
    condition = var.autoscaling == null || try(
      var.autoscaling.min_capacity >= 1 &&
      var.autoscaling.min_capacity <= var.autoscaling.max_capacity &&
      var.autoscaling.cpu_target > 0 && var.autoscaling.cpu_target <= 100 &&
      var.autoscaling.scale_in_cooldown >= 0 && var.autoscaling.scale_out_cooldown >= 0,
      false,
    )
    error_message = "autoscaling needs min_capacity >= 1, min_capacity <= max_capacity, cpu_target in 1-100, and non-negative cooldowns."
  }
}

variable "log_level" {
  type        = string
  description = "LOG_LEVEL environment variable value."
  default     = "info"
  nullable    = false

  validation {
    condition     = contains(["debug", "info", "warn", "error"], var.log_level)
    error_message = "log_level must be one of: debug, info, warn, error."
  }
}

variable "tags" {
  type        = map(string)
  description = "Additional tags merged onto every resource."
  default     = {}
  nullable    = false
}
