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
  description = "AWS region for the EKS production environment."
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

variable "kubernetes_version" {
  type        = string
  description = "EKS Kubernetes version."
  nullable    = false
}

variable "node_instance_type" {
  type        = string
  description = "Default EKS managed node group instance type."
  nullable    = false
}

variable "node_disk_size_gb" {
  type        = number
  description = "Default EKS managed node group root disk size in GiB."
  nullable    = false
}

variable "node_scaling" {
  type = object({
    desired = number
    min     = number
    max     = number
  })
  description = "Default EKS managed node group capacity."
  nullable    = false
}

variable "endpoint_public_access" {
  type        = bool
  description = "Expose the EKS API publicly. Requires explicit CIDRs."
  nullable    = false
}

variable "endpoint_public_access_cidrs" {
  type        = list(string)
  description = "Explicit CIDRs allowed to reach the EKS public endpoint."
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
