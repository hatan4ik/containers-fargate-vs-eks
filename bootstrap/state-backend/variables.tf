variable "region" {
  type        = string
  description = "AWS region containing the state bucket and KMS key."
  nullable    = false
}

variable "name" {
  type        = string
  description = "Organization/project prefix for state and CI identity resources."
  nullable    = false

  validation {
    condition     = can(regex("^[a-z0-9-]{3,40}$", var.name))
    error_message = "name must be 3-40 lowercase letters, numbers, or hyphens."
  }
}

variable "state_bucket_name" {
  type        = string
  description = "Globally unique S3 bucket name for Terraform state."
  nullable    = false
}

variable "access_log_bucket_name" {
  type        = string
  description = "Dedicated pre-provisioned S3 bucket that receives state-bucket server access logs."
  nullable    = false
}

variable "replica_bucket_arn" {
  type        = string
  description = "Versioned, cross-region S3 bucket ARN used for Terraform state disaster recovery."
  nullable    = false
}

variable "replica_kms_key_arn" {
  type        = string
  description = "Customer-managed KMS key ARN in the replica region for replicated state objects."
  nullable    = false
}

variable "kms_key_account_root_arn" {
  type        = string
  description = "AWS account root principal ARN that enables IAM policies to administer and use the state KMS key."
  nullable    = false
}

variable "github_repository" {
  type        = string
  description = "GitHub repository allowed to receive OIDC credentials."
  default     = "hatan4ik/containers-fargate-vs-eks"
  nullable    = false
}

variable "github_oidc_provider_arn" {
  type        = string
  description = "Existing GitHub Actions OIDC provider ARN, or null to create it."
  default     = null
}

variable "apply_policy_arns" {
  type        = map(set(string))
  description = "Approved least-privilege workload policy ARNs keyed by fargate-dev, fargate-prod, eks-dev, and eks-prod."
  nullable    = false

  validation {
    condition = toset(keys(var.apply_policy_arns)) == toset(["fargate-dev", "fargate-prod", "eks-dev", "eks-prod"]) && alltrue([
      for policy_arns in values(var.apply_policy_arns) : length(policy_arns) > 0
    ])
    error_message = "apply_policy_arns must define at least one policy ARN for each supported environment key."
  }
}

variable "tags" {
  type        = map(string)
  description = "Additional governance tags. Required bootstrap tags take precedence."
  default     = {}
  nullable    = false
}
