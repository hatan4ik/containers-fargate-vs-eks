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

variable "access_log_bucket_name" {
  type        = string
  description = "Dedicated pre-provisioned S3 bucket that receives state-bucket server access logs. Its bucket policy must allow S3 log delivery."
  nullable    = false

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.access_log_bucket_name))
    error_message = "access_log_bucket_name must be a valid 3-63 character S3 bucket name."
  }
}

variable "access_log_prefix" {
  type        = string
  description = "Prefix used for S3 server access logs in access_log_bucket_name."
  default     = "terraform-state"
  nullable    = false
}

variable "replica_bucket_arn" {
  type        = string
  description = "Versioned, cross-region S3 bucket ARN that receives replicated state objects."
  nullable    = false

  validation {
    condition     = can(regex("^arn:[^:]+:s3:::[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.replica_bucket_arn))
    error_message = "replica_bucket_arn must be an S3 bucket ARN."
  }
}

variable "replica_kms_key_arn" {
  type        = string
  description = "Customer-managed KMS key ARN in the replica region. Its key policy must allow the source replication role to encrypt objects."
  nullable    = false

  validation {
    condition     = can(regex("^arn:[^:]+:kms:[^:]+:[0-9]{12}:key/.+$", var.replica_kms_key_arn))
    error_message = "replica_kms_key_arn must be a KMS key ARN."
  }
}

variable "kms_key_account_root_arn" {
  type        = string
  description = "AWS account root principal ARN that enables IAM policies to administer and use the state KMS key."
  nullable    = false

  validation {
    condition     = can(regex("^arn:[^:]+:iam::[0-9]{12}:root$", var.kms_key_account_root_arn))
    error_message = "kms_key_account_root_arn must be an AWS account root principal ARN."
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
