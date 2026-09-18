variable "name" {
  type        = string
  description = "Lowercase name prefix used for the KMS alias and required tags."
  nullable    = false

  validation {
    condition     = can(regex("^[a-z0-9-]{3,40}$", var.name))
    error_message = "name must be 3-40 lowercase letters, numbers, or hyphens."
  }
}

variable "bucket_name" {
  type        = string
  description = "Globally unique S3 bucket name used exclusively for Terraform state."
  nullable    = false

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "bucket_name must be a valid 3-63 character S3 bucket name."
  }
}

variable "noncurrent_version_expiration_days" {
  type        = number
  description = "Number of days to retain non-current state versions for recovery. Current state is never expired."
  default     = 365
  nullable    = false

  validation {
    condition     = var.noncurrent_version_expiration_days >= 90 && var.noncurrent_version_expiration_days <= 3650
    error_message = "noncurrent_version_expiration_days must be between 90 and 3650."
  }
}

variable "tags" {
  type        = map(string)
  description = "Additional tags. Required module tags take precedence."
  default     = {}
  nullable    = false
}
