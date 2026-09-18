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
  default     = 365
  nullable    = false

  validation {
    condition     = var.retention_days >= 365 && contains([365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653], var.retention_days)
    error_message = "retention_days must be an accepted CloudWatch Logs value of at least 365 days."
  }
}

variable "kms_key_id" {
  type        = string
  description = "Customer-managed KMS key ARN for CloudWatch Logs encryption. The key policy must permit the regional CloudWatch Logs service."
  nullable    = false

  validation {
    condition     = can(regex("^arn:[^:]+:kms:[^:]+:[0-9]{12}:key/.+$", var.kms_key_id))
    error_message = "kms_key_id must be a KMS key ARN, not an alias or key ID."
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the log group."
  default     = {}
  nullable    = false
}
