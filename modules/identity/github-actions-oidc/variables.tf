variable "name" {
  type        = string
  description = "Lowercase name prefix for IAM roles."
  nullable    = false

  validation {
    condition     = can(regex("^[a-z0-9-]{3,40}$", var.name))
    error_message = "name must be 3-40 lowercase letters, numbers, or hyphens."
  }
}

variable "github_repository" {
  type        = string
  description = "GitHub repository allowed to request OIDC credentials, in owner/repository form."
  nullable    = false

  validation {
    condition     = can(regex("^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$", var.github_repository))
    error_message = "github_repository must be in owner/repository form."
  }
}

variable "github_oidc_provider_arn" {
  type        = string
  description = "Existing GitHub Actions OIDC provider ARN. Set to null to create it in this AWS account."
  default     = null
}

variable "state_bucket_arn" {
  type        = string
  description = "ARN of the Terraform state bucket."
  nullable    = false
}

variable "kms_key_arn" {
  type        = string
  description = "ARN of the KMS key encrypting Terraform state."
  nullable    = false
}

variable "environments" {
  type = map(object({
    github_environment = string
    state_key          = string
    apply_policy_arns  = set(string)
  }))
  description = "Stable environment keys with GitHub Environment names, dedicated state keys, and explicitly approved apply policies."
  nullable    = false

  validation {
    condition = length(var.environments) > 0 && alltrue([
      for environment in values(var.environments) :
      length(environment.github_environment) > 0 &&
      can(regex("^[a-z0-9][a-z0-9/_-]+\\.tfstate$", environment.state_key)) &&
      length(environment.apply_policy_arns) > 0
    ])
    error_message = "Every environment must define a GitHub Environment, a relative *.tfstate key, and at least one approved apply policy ARN."
  }
}

variable "tags" {
  type        = map(string)
  description = "Additional tags. Required module tags take precedence."
  default     = {}
  nullable    = false
}
