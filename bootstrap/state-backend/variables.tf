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
