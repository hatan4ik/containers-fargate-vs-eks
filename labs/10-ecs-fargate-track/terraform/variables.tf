variable "region" {
  type        = string
  description = "AWS region where the Fargate lab resources are created."
  default     = "us-east-1"
}
variable "name" {
  type        = string
  description = "Prefix applied to Fargate lab resource names."
  default     = "z2h"
}
variable "vpc_cidr" {
  type        = string
  description = "IPv4 CIDR block for the Fargate lab VPC."
  default     = "10.40.0.0/16"
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

variable "image_gateway" {
  type        = string
  description = "Immutable container image URI for the gateway service."
  validation {
    condition     = can(regex("(@sha256:[0-9a-f]{64}|:sha-[0-9a-f]{40})$", var.image_gateway))
    error_message = "image_gateway must use an immutable digest or a sha-<40 hex> tag."
  }
}
variable "image_users" {
  type        = string
  description = "Immutable container image URI for the users service."
  validation {
    condition     = can(regex("(@sha256:[0-9a-f]{64}|:sha-[0-9a-f]{40})$", var.image_users))
    error_message = "image_users must use an immutable digest or a sha-<40 hex> tag."
  }
}
variable "image_orders" {
  type        = string
  description = "Immutable container image URI for the orders service."
  validation {
    condition     = can(regex("(@sha256:[0-9a-f]{64}|:sha-[0-9a-f]{40})$", var.image_orders))
    error_message = "image_orders must use an immutable digest or a sha-<40 hex> tag."
  }
}
