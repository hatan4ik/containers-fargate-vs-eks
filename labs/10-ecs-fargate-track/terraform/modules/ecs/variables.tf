variable "name" { type = string }
variable "vpc_id" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "private_subnet_ids" { type = list(string) }

variable "log_group_name" { type = string }

variable "image_gateway" { type = string }
variable "image_users" { type = string }
variable "image_orders" { type = string }
