variable "name" {
  type        = string
  description = "Name prefix applied to every resource in this module."

  validation {
    condition     = can(regex("^[a-z0-9-]{1,24}$", var.name))
    error_message = "name must be 1-24 lowercase alphanumeric characters or hyphens."
  }
}

variable "cidr" {
  type        = string
  description = "IPv4 CIDR block for the VPC (e.g. 10.40.0.0/16)."

  validation {
    condition     = can(cidrnetmask(var.cidr)) && can(cidrsubnet(var.cidr, 8, 0))
    error_message = "cidr must be a valid CIDR block with room for derived /24 subnets."
  }
}

variable "availability_zones" {
  type        = list(string)
  description = "Explicit list of AZ names to use (e.g. [\"us-east-1a\",\"us-east-1b\"]). Length must be 2 or 3."

  validation {
    condition     = length(var.availability_zones) >= 2 && length(var.availability_zones) <= 3 && length(distinct(var.availability_zones)) == length(var.availability_zones)
    error_message = "availability_zones must contain 2 or 3 unique entries."
  }
}

variable "single_nat_gateway" {
  type        = bool
  description = "Use one NAT gateway (cost saving) instead of one per AZ (fault tolerant)."
  default     = false
  nullable    = false
}

variable "flow_log_retention_days" {
  type        = number
  description = "CloudWatch log retention in days for VPC flow logs."
  default     = 365
  nullable    = false

  validation {
    condition     = var.flow_log_retention_days >= 365 && contains([365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653], var.flow_log_retention_days)
    error_message = "flow_log_retention_days must be an accepted CloudWatch Logs value of at least 365 days."
  }
}

variable "flow_log_kms_key_id" {
  type        = string
  description = "Customer-managed KMS key ARN used to encrypt VPC flow logs. Use a key policy that permits the regional CloudWatch Logs service."
  nullable    = false

  validation {
    condition     = can(regex("^arn:[^:]+:kms:[^:]+:[0-9]{12}:key/.+$", var.flow_log_kms_key_id))
    error_message = "flow_log_kms_key_id must be a KMS key ARN, not an alias or key ID."
  }
}

variable "flow_log_group_name" {
  type        = string
  description = "Existing-compatible VPC flow-log group name. Null derives /<name>/vpc-flow-logs."
  default     = null
}

variable "flow_log_role_name" {
  type        = string
  description = "Existing-compatible VPC flow-log IAM role name. Null derives <name>-vpc-flow-logs."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Additional tags merged onto every resource."
  default     = {}
  nullable    = false
}

variable "eks_subnet_tags" {
  type        = bool
  description = "When true, add kubernetes.io/role/elb and kubernetes.io/role/internal-elb tags to subnets (required for EKS load-balancer controllers)."
  default     = false
  nullable    = false
}
