variable "name" {
  type        = string
  description = "Lowercase prefix for the OIDC provider's IAM roles."
  nullable    = false

  validation {
    condition     = can(regex("^[a-z0-9-]{3,63}$", var.name))
    error_message = "name must be 3-63 lowercase letters, numbers, or hyphens."
  }
}

variable "issuer_url" {
  type        = string
  description = "Public HTTPS OIDC issuer URL, without a trailing slash."
  nullable    = false

  validation {
    condition     = can(regex("^https://[^/?#]+(?:/[^?#]+)?$", var.issuer_url)) && !endswith(var.issuer_url, "/")
    error_message = "issuer_url must be a public HTTPS URL without a trailing slash, query, or fragment."
  }
}

variable "audience" {
  type        = string
  description = "OIDC audience accepted by AWS for this issuer."
  nullable    = false

  validation {
    condition     = length(trimspace(var.audience)) > 0
    error_message = "audience must not be empty."
  }
}

variable "thumbprint_list" {
  type        = list(string)
  description = "One or more SHA-1 TLS certificate thumbprints for the issuer, verified before apply."
  nullable    = false

  validation {
    condition     = length(var.thumbprint_list) > 0 && alltrue([for thumbprint in var.thumbprint_list : can(regex("^[0-9a-fA-F]{40}$", thumbprint))])
    error_message = "thumbprint_list must contain one or more 40-character SHA-1 hexadecimal thumbprints."
  }
}

variable "roles" {
  type = map(object({
    subject                  = string
    policy_arns              = set(string)
    additional_string_equals = optional(map(set(string)), {})
  }))
  description = "Stable role keys, exact OIDC subjects, least-privilege policy ARNs, and optional issuer-specific exact claim constraints."
  nullable    = false

  validation {
    condition = length(var.roles) > 0 && alltrue([
      for role_key, role in var.roles :
      can(regex("^[a-z0-9-]{3,32}$", role_key)) &&
      length("${var.name}-${role_key}") <= 64 &&
      length(trimspace(role.subject)) > 0 &&
      length(role.policy_arns) > 0 &&
      alltrue([for policy_arn in role.policy_arns : can(regex("^arn:[^:]+:iam::[0-9]{12}:policy/.+$", policy_arn))]) &&
      alltrue([for values in values(role.additional_string_equals) : length(values) > 0])
    ])
    error_message = "Every role needs a stable key, a <=64-character role name, exact subject, at least one customer-managed IAM policy ARN, and non-empty additional claim values."
  }
}

variable "tags" {
  type        = map(string)
  description = "Additional tags. Required module tags take precedence."
  default     = {}
  nullable    = false
}
