variable "name" {
  type        = string
  description = "Name prefix for all resources in this module."

  validation {
    condition     = can(regex("^[a-z0-9-]{1,24}$", var.name))
    error_message = "name must be 1-24 lowercase alphanumeric characters or hyphens."
  }
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the cluster and ALB are deployed."
  nullable    = false
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block — used to scope security group egress rules."

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr must be a valid CIDR block."
  }
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public subnet IDs for the ALB."

  validation {
    condition     = length(var.public_subnet_ids) >= 2
    error_message = "At least 2 public subnets are required for an ALB."
  }
}

variable "certificate_arn" {
  type        = string
  description = "ACM certificate ARN for the mandatory TLS listener on the ALB."
  nullable    = false

  validation {
    condition     = can(regex("^arn:[^:]+:acm:[^:]+:[0-9]{12}:certificate/.+$", var.certificate_arn))
    error_message = "certificate_arn must be an ACM certificate ARN."
  }
}

variable "alb_ingress_cidrs" {
  type        = set(string)
  description = "CIDRs permitted to reach the ALB. Empty creates no public listener ingress."
  default     = []
  nullable    = false

  validation {
    condition     = alltrue([for cidr in var.alb_ingress_cidrs : can(cidrnetmask(cidr))])
    error_message = "alb_ingress_cidrs must contain valid CIDR blocks."
  }
}

variable "allow_public_ingress" {
  type        = bool
  description = "Explicitly permit 0.0.0.0/0 ALB ingress. Keep false unless a public internet-facing endpoint is required."
  default     = false
  nullable    = false
}

variable "alb_access_logs" {
  type = object({
    bucket = string
    prefix = optional(string, "alb")
  })
  description = "Pre-provisioned S3 bucket and prefix for ALB access logs. The bucket policy must allow the ALB log-delivery service for this account and region."
  nullable    = false

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.alb_access_logs.bucket))
    error_message = "alb_access_logs.bucket must be a valid S3 bucket name."
  }
}

variable "enable_deletion_protection" {
  type        = bool
  description = "Protect the ALB from accidental deletion. Keep true in every persistent environment."
  default     = true
  nullable    = false
}

variable "waf_log_destination_arn" {
  type        = string
  description = "Kinesis Data Firehose delivery stream ARN for WAF logs. AWS requires its delivery stream name to begin aws-waf-logs-."
  nullable    = false

  validation {
    condition     = can(regex("^arn:[^:]+:firehose:[^:]+:[0-9]{12}:deliverystream/aws-waf-logs-.+$", var.waf_log_destination_arn))
    error_message = "waf_log_destination_arn must be an aws-waf-logs-* Kinesis Data Firehose ARN."
  }
}

variable "container_insights" {
  type        = bool
  description = "Enable ECS Container Insights on the cluster."
  default     = true
  nullable    = false
}

variable "tags" {
  type        = map(string)
  description = "Additional tags merged onto every resource."
  default     = {}
  nullable    = false
}
