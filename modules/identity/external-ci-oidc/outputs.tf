output "oidc_provider_arn" {
  description = "ARN of the OIDC provider created for this CI platform."
  value       = aws_iam_openid_connect_provider.this.arn
}

output "role_arns" {
  description = "IAM role ARNs keyed by the stable role key."
  value       = { for key, role in aws_iam_role.this : key => role.arn }
}
