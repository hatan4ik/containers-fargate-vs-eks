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

variable "providers" {
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
    condition     = length(var.providers) > 0 && alltrue([for provider_key in keys(var.providers) : can(regex("^[a-z0-9-]{3,20}$", provider_key))])
    error_message = "providers needs at least one stable lowercase provider key."
  }
}

variable "tags" {
  type        = map(string)
  description = "Additional governance tags. Required bootstrap tags take precedence."
  default     = {}
  nullable    = false

  validation {
    condition     = contains(keys(var.tags), "Owner") && contains(keys(var.tags), "CostCenter")
    error_message = "tags must include Owner and CostCenter."
  }
}
