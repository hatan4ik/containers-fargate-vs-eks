variable "region" {
  type        = string
  description = "AWS region used by the provider while provisioning account-level IAM resources."
  nullable    = false

  validation {
    condition     = can(regex("^[a-z]{2}(-gov)?-[a-z]+-[0-9]$", var.region))
    error_message = "region must be a valid AWS region identifier."
  }
}

variable "name" {
  type        = string
  description = "Lowercase prefix for external CI OIDC providers and roles."
  nullable    = false

  validation {
    condition     = can(regex("^[a-z0-9-]{3,28}$", var.name))
    error_message = "name must be 3-28 lowercase letters, numbers, or hyphens."
  }
}

variable "oidc_providers" {
  type = map(object({
    issuer_url      = string
    audience        = string
    thumbprint_list = list(string)
    roles = map(object({
      subject                  = string
      policy_arns              = set(string)
      additional_string_equals = optional(map(set(string)), {})
    }))
  }))
  description = "External CI issuers and their exact-subject IAM roles. Use one map entry per issuer, such as gitlab or azure-devops."
  nullable    = false

  validation {
    condition = length(var.oidc_providers) > 0 && alltrue([
      for provider_key, provider in var.oidc_providers :
      can(regex("^[a-z0-9-]{3,20}$", provider_key)) &&
      alltrue([for role_key in keys(provider.roles) : length("${var.name}-${provider_key}-${role_key}") <= 64])
    ])
    error_message = "oidc_providers needs stable lowercase keys and every generated IAM role name must be 64 characters or fewer."
  }
}

variable "tags" {
  type        = map(string)
  description = "Additional governance tags. Required bootstrap tags take precedence."
  default     = {}
  nullable    = false

  validation {
    condition     = contains(keys(var.tags), "Owner") && contains(keys(var.tags), "CostCenter") && length(trimspace(var.tags.Owner)) > 0 && length(trimspace(var.tags.CostCenter)) > 0
    error_message = "tags must include non-empty Owner and CostCenter values."
  }
}
