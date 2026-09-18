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
  description = "ACM certificate ARN for HTTPS on the ALB. When provided, port 80 redirects to 443."
  default     = null
}

variable "allow_insecure_http" {
  type        = bool
  description = "Explicitly permit HTTP-only ALB traffic when no certificate is provided. Keep false for production."
  default     = false
  nullable    = false
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
