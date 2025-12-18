variable "region" { type = string, default = "us-east-1" }
variable "name"   { type = string, default = "z2h" }
variable "vpc_cidr" { type = string, default = "10.40.0.0/16" }

variable "image_gateway" { type = string }
variable "image_users"   { type = string }
variable "image_orders"  { type = string }
