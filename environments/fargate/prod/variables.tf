variable "organization" {
  type        = string
  description = "Lowercase organization identifier included in canonical resource names and tags."
  nullable    = false

  validation {
    condition     = can(regex("^[a-z0-9-]{3,24}$", var.organization))
    error_message = "organization must be 3-24 lowercase letters, numbers, or hyphens."
  }
}

variable "region" {
  type        = string
  description = "AWS region for the Fargate production environment."
  nullable    = false
}

variable "migration_name_override" {
  type        = string
  description = "Temporary existing-resource prefix used only during a plan-verified state migration. Null uses the canonical name."
  default     = null
}

variable "vpc_cidr" {
  type        = string
  description = "IPv4 CIDR block for the production VPC."
  nullable    = false
}

variable "availability_zones" {
  type        = list(string)
  description = "Two or three explicit availability-zone names."
  nullable    = false
}

variable "single_nat_gateway" {
  type        = bool
  description = "Use a single NAT gateway. Production should normally set false."
  nullable    = false
}

variable "service_images" {
  type = object({
    gateway = string
    orders  = string
    users   = string
  })
  description = "Immutable digest- or commit-SHA-pinned container image URIs."
  nullable    = false

  validation {
    condition = alltrue([
      for image in values(var.service_images) :
      can(regex("(@sha256:[0-9a-f]{64}|:sha-[0-9a-f]{40})$", image))
    ])
    error_message = "Every service image must use a digest or sha-<40 hex> tag."
  }
}

variable "service_desired_counts" {
  type = object({
    gateway = number
    orders  = number
    users   = number
  })
  description = "Desired Fargate task count for each service."
  nullable    = false
}

variable "gateway_autoscaling" {
  type = object({
    min_capacity       = number
    max_capacity       = number
    cpu_target         = optional(number, 50)
    scale_in_cooldown  = optional(number, 60)
    scale_out_cooldown = optional(number, 60)
  })
  description = "Required gateway CPU autoscaling configuration."
  nullable    = false
}

variable "certificate_arn" {
  type        = string
  description = "Validated ACM certificate ARN for production HTTPS."
  nullable    = false
}

variable "flow_log_kms_key_id" {
  type        = string
  description = "Customer-managed KMS key ARN used to encrypt VPC flow logs."
  nullable    = false
}

variable "application_log_kms_key_id" {
  type        = string
  description = "Customer-managed KMS key ARN used to encrypt application logs."
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

variable "waf_log_destination_arn" {
  type        = string
  description = "Kinesis Data Firehose delivery stream ARN for mandatory WAF logs."
  nullable    = false
}

variable "alb_ingress_cidrs" {
  type        = set(string)
  description = "CIDRs permitted to reach the production application load balancer."
  nullable    = false
}

variable "https_egress_cidrs" {
  type        = set(string)
  description = "CIDRs permitted for outbound HTTPS. Prefer VPC endpoints and narrow ranges."
  nullable    = false
}

variable "tags" {
  type        = map(string)
  description = "Additional governance tags. Owner and CostCenter are mandatory."
  nullable    = false

  validation {
    condition     = alltrue([for key in ["Owner", "CostCenter"] : contains(keys(var.tags), key) && length(trimspace(var.tags[key])) > 0])
    error_message = "tags must contain non-empty Owner and CostCenter values."
  }
}
