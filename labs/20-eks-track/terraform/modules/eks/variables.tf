variable "name" { type = string }
variable "vpc_id" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "private_subnet_ids" { type = list(string) }

variable "kubernetes_version" { type = string, default = "1.30" }
variable "node_instance_type" { type = string, default = "t3.medium" }

variable "enable_helm_addons" { type = bool, default = true }
variable "enable_istio" { type = bool, default = false }
