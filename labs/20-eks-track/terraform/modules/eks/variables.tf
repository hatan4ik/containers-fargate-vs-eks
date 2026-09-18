variable "name" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "private_subnet_ids" { type = list(string) }

variable "kubernetes_version" {
  type    = string
  default = "1.30"
}
variable "node_instance_type" {
  type    = string
  default = "t3.medium"
}
variable "endpoint_public_access" { type = bool }
variable "endpoint_public_access_cidrs" { type = list(string) }
