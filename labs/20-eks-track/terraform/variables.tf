variable "region" { type = string, default = "us-east-1" }
variable "name" { type = string, default = "z2h" }
variable "vpc_cidr" { type = string, default = "10.50.0.0/16" }

variable "enable_helm_addons" { type = bool, default = true }
variable "enable_istio" { type = bool, default = false }
