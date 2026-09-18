variable "name" {
  type        = string
  description = "Stable resource-name prefix, normally <organization>-<environment>-<region>."
  nullable    = false

  validation {
    condition     = can(regex("^[a-z0-9-]{1,24}$", var.name))
    error_message = "name must be 1-24 lowercase letters, numbers, or hyphens."
  }
}

variable "region" {
  type        = string
  description = "AWS region passed to Fargate task log configuration."
  nullable    = false
}

variable "vpc_cidr" {
  type        = string
  description = "IPv4 CIDR block for the workload VPC."
  nullable    = false

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr must be a valid IPv4 CIDR."
  }
}

variable "availability_zones" {
  type        = list(string)
  description = "Two or three explicit availability-zone names used by the VPC."
  nullable    = false
}

variable "single_nat_gateway" {
  type        = bool
  description = "Use one NAT gateway for a cost-optimized non-production topology."
  default     = false
  nullable    = false
}

variable "flow_log_group_name" {
  type        = string
  description = "Optional compatibility name for the VPC flow-log group. Null derives a canonical name."
  default     = null
}

variable "flow_log_role_name" {
  type        = string
  description = "Optional compatibility name for the VPC flow-log role. Null derives a canonical name."
  default     = null
}

variable "flow_log_retention_days" {
  type        = number
  description = "VPC flow-log retention in days."
  default     = 365
  nullable    = false
}

variable "flow_log_kms_key_id" {
  type        = string
  description = "Customer-managed KMS key ARN used to encrypt VPC flow logs."
  nullable    = false
}

variable "application_log_retention_days" {
  type        = number
  description = "Application log retention in days."
  default     = 365
  nullable    = false
}

variable "application_log_kms_key_id" {
  type        = string
  description = "Customer-managed KMS key ARN used to encrypt application logs."
  nullable    = false
}

variable "certificate_arn" {
  type        = string
  description = "Validated ACM certificate ARN for the mandatory ALB HTTPS listener."
  nullable    = false
}

variable "alb_ingress_cidrs" {
  type        = set(string)
  description = "CIDRs permitted to reach the application load balancer."
  default     = []
  nullable    = false
}

variable "allow_public_ingress" {
  type        = bool
  description = "Explicitly allow 0.0.0.0/0 ALB ingress."
  default     = false
  nullable    = false
}

variable "alb_access_logs" {
  type = object({
    bucket = string
    prefix = optional(string, "alb")
  })
  description = "Pre-provisioned S3 destination for ALB access logs."
  nullable    = false
}

variable "enable_deletion_protection" {
  type        = bool
  description = "Prevent accidental ALB deletion."
  default     = true
  nullable    = false
}

variable "waf_log_destination_arn" {
  type        = string
  description = "Kinesis Data Firehose delivery stream ARN for mandatory WAF logs."
  nullable    = false
}

variable "https_egress_cidrs" {
  type        = set(string)
  description = "CIDRs permitted for outbound HTTPS from every task. Prefer VPC endpoints and narrow CIDRs."
  default     = []
  nullable    = false
}

variable "allow_public_https_egress" {
  type        = bool
  description = "Explicitly permit 0.0.0.0/0 HTTPS egress for every task."
  default     = false
  nullable    = false
}

variable "services" {
  type = object({
    gateway = object({
      image         = string
      desired_count = optional(number, 2)
      autoscaling = optional(object({
        min_capacity       = number
        max_capacity       = number
        cpu_target         = optional(number, 50)
        scale_in_cooldown  = optional(number, 60)
        scale_out_cooldown = optional(number, 60)
      }))
      extra_egress_rules = optional(list(object({
        description      = string
        from_port        = number
        to_port          = number
        ip_protocol      = string
        cidr_ipv4        = optional(string)
        referenced_sg_id = optional(string)
      })), [])
    })
    orders = object({
      image         = string
      desired_count = optional(number, 2)
      autoscaling = optional(object({
        min_capacity       = number
        max_capacity       = number
        cpu_target         = optional(number, 50)
        scale_in_cooldown  = optional(number, 60)
        scale_out_cooldown = optional(number, 60)
      }))
      extra_egress_rules = optional(list(object({
        description      = string
        from_port        = number
        to_port          = number
        ip_protocol      = string
        cidr_ipv4        = optional(string)
        referenced_sg_id = optional(string)
      })), [])
    })
    users = object({
      image         = string
      desired_count = optional(number, 2)
      autoscaling = optional(object({
        min_capacity       = number
        max_capacity       = number
        cpu_target         = optional(number, 50)
        scale_in_cooldown  = optional(number, 60)
        scale_out_cooldown = optional(number, 60)
      }))
      extra_egress_rules = optional(list(object({
        description      = string
        from_port        = number
        to_port          = number
        ip_protocol      = string
        cidr_ipv4        = optional(string)
        referenced_sg_id = optional(string)
      })), [])
    })
  })
  description = "Immutable images and per-service capacity/egress configuration for the gateway, orders, and users topology."
  nullable    = false
}

variable "tags" {
  type        = map(string)
  description = "Additional tags. Required module tags take precedence."
  default     = {}
  nullable    = false
}
