variable "name" {
  type        = string
  description = "Stable resource-name prefix, normally <organization>-<environment>-<region>."
  nullable    = false

  validation {
    condition     = can(regex("^[a-z0-9-]{1,24}$", var.name))
    error_message = "name must be 1-24 lowercase letters, numbers, or hyphens."
  }
}

variable "vpc_cidr" {
  type        = string
  description = "IPv4 CIDR block for the EKS VPC."
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

variable "cluster_log_retention_days" {
  type        = number
  description = "EKS control-plane log retention in days."
  default     = 365
  nullable    = false
}

variable "cluster_log_kms_key_id" {
  type        = string
  description = "Customer-managed KMS key ARN used to encrypt EKS control-plane logs."
  nullable    = false
}

variable "kubernetes_version" {
  type        = string
  description = "EKS Kubernetes version."
  default     = "1.30"
  nullable    = false
}

variable "node_instance_type" {
  type        = string
  description = "EC2 instance type for the default EKS managed node group."
  default     = "t3.medium"
  nullable    = false
}

variable "node_disk_size_gb" {
  type        = number
  description = "Root disk size for the default EKS managed node group."
  default     = 50
  nullable    = false
}

variable "node_scaling" {
  type = object({
    desired = optional(number, 2)
    min     = optional(number, 2)
    max     = optional(number, 5)
  })
  description = "Default EKS managed node group capacity."
  default     = {}
  nullable    = false
}

variable "secrets_kms_key_arn" {
  type        = string
  description = "Dedicated customer-managed KMS key ARN for Kubernetes Secret envelope encryption."
  nullable    = false
}

variable "tags" {
  type        = map(string)
  description = "Additional tags. Required module tags take precedence."
  default     = {}
  nullable    = false
}
