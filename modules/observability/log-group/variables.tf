variable "name" {
  type        = string
  description = "CloudWatch log group name (full path, e.g. /z2h/dev/apps)."

  validation {
    condition     = can(regex("^/[a-zA-Z0-9/_-]{1,511}$", var.name))
    error_message = "name must start with / and contain only alphanumeric, /, _, - characters (max 512 chars total)."
  }
}

variable "retention_days" {
  type        = number
  description = "Log retention in days."
  default     = 14
  nullable    = false

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653], var.retention_days)
    error_message = "retention_days must be a value accepted by CloudWatch Logs."
  }
}

variable "kms_key_id" {
  type        = string
  description = "Optional KMS key ARN for CloudWatch Logs encryption. Null uses the AWS-managed default."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the log group."
  default     = {}
  nullable    = false
}
