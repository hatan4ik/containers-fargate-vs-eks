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
  default = "10.40.0.0/16"
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
  type = string
  validation {
    condition     = can(regex("(@sha256:[0-9a-f]{64}|:sha-[0-9a-f]{40})$", var.image_gateway))
    error_message = "image_gateway must use an immutable digest or a sha-<40 hex> tag."
  }
}
variable "image_users" {
  type = string
  validation {
    condition     = can(regex("(@sha256:[0-9a-f]{64}|:sha-[0-9a-f]{40})$", var.image_users))
    error_message = "image_users must use an immutable digest or a sha-<40 hex> tag."
  }
}
variable "image_orders" {
  type = string
  validation {
    condition     = can(regex("(@sha256:[0-9a-f]{64}|:sha-[0-9a-f]{40})$", var.image_orders))
    error_message = "image_orders must use an immutable digest or a sha-<40 hex> tag."
  }
}
