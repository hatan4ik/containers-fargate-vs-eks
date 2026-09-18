variable "name" { type = string }
variable "cidr" {
  type = string

  validation {
    condition     = can(cidrnetmask(var.cidr))
    error_message = "cidr must be a valid CIDR block."
  }
}
variable "availability_zone_count" { type = number }
variable "single_nat_gateway" { type = bool }
variable "flow_log_group_name" { type = string }
variable "flow_log_role_name" { type = string }
