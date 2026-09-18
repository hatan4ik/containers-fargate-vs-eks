variable "region" {
  type    = string
  default = "us-east-1"
}
variable "name" {
  type    = string
  default = "z2h"
}
variable "vpc_cidr" {
  type    = string
  default = "10.50.0.0/16"
}
variable "availability_zone_count" {
  type        = number
  default     = 2
  description = "Number of availability zones. Two is the minimum resilient topology."

  validation {
    condition     = var.availability_zone_count >= 2 && var.availability_zone_count <= 3
    error_message = "availability_zone_count must be between 2 and 3."
  }
}
variable "single_nat_gateway" {
  type        = bool
  default     = false
  description = "Use one NAT gateway to reduce cost at the expense of AZ fault tolerance."
}
variable "endpoint_public_access" {
  type        = bool
  default     = false
  description = "Keep the Kubernetes API private unless an explicitly allow-listed management path is required."
}
variable "endpoint_public_access_cidrs" {
  type        = list(string)
  default     = []
  description = "CIDRs allowed to use the EKS public API endpoint when endpoint_public_access is true."

  validation {
    condition     = alltrue([for cidr in var.endpoint_public_access_cidrs : can(cidrnetmask(cidr))])
    error_message = "endpoint_public_access_cidrs must contain valid CIDR blocks."
  }
}
