variable "name" {
  type        = string
  description = "Name prefix for all resources."

  validation {
    condition     = can(regex("^[a-z0-9-]{1,24}$", var.name))
    error_message = "name must be 1-24 lowercase alphanumeric characters or hyphens."
  }
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public subnet IDs (tagged kubernetes.io/role/elb=1 by the vpc module)."

  validation {
    condition     = length(var.public_subnet_ids) >= 2
    error_message = "At least 2 public subnets are required."
  }
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for node groups (tagged kubernetes.io/role/internal-elb=1)."

  validation {
    condition     = length(var.private_subnet_ids) >= 2
    error_message = "At least 2 private subnets are required."
  }
}

variable "kubernetes_version" {
  type        = string
  description = "EKS Kubernetes version (e.g. \"1.30\")."
  default     = "1.30"
  nullable    = false

  validation {
    condition     = can(regex("^1\\.[0-9]{2}$", var.kubernetes_version))
    error_message = "kubernetes_version must match pattern 1.XX (e.g. 1.30)."
  }
}

variable "node_instance_type" {
  type        = string
  description = "EC2 instance type for the default node group."
  default     = "t3.medium"
  nullable    = false
}

variable "node_scaling" {
  type = object({
    desired = optional(number, 2)
    min     = optional(number, 2)
    max     = optional(number, 5)
  })
  description = "Node group scaling configuration."
  default     = {}
  nullable    = false

  validation {
    condition = (
      var.node_scaling.min >= 0 &&
      var.node_scaling.desired >= 0 &&
      var.node_scaling.max >= 1
    )
    error_message = "node_scaling values must be non-negative and max must be at least 1."
  }
}

variable "node_disk_size_gb" {
  type        = number
  description = "Root EBS volume size in GiB for each node."
  default     = 50
  nullable    = false

  validation {
    condition     = var.node_disk_size_gb >= 20 && var.node_disk_size_gb <= 16384
    error_message = "node_disk_size_gb must be between 20 and 16384 GiB."
  }
}

variable "endpoint_public_access" {
  type        = bool
  description = "Expose the Kubernetes API endpoint publicly. Requires endpoint_public_access_cidrs."
  default     = false
  nullable    = false
}

variable "endpoint_public_access_cidrs" {
  type        = list(string)
  description = "CIDRs allowed to reach the public API endpoint. Required when endpoint_public_access = true."
  default     = []
  nullable    = false

  validation {
    condition     = alltrue([for c in var.endpoint_public_access_cidrs : can(cidrnetmask(c))])
    error_message = "endpoint_public_access_cidrs must contain valid CIDR blocks."
  }
}

variable "tags" {
  type        = map(string)
  description = "Additional tags merged onto every resource."
  default     = {}
  nullable    = false
}
