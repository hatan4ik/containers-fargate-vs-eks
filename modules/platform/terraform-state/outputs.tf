output "bucket_name" {
  description = "Terraform state bucket name."
  value       = var.bucket_name
}

output "bucket_arn" {
  description = "Terraform state bucket ARN."
  value       = aws_s3_bucket.state.arn
}

output "kms_key_arn" {
  description = "KMS key ARN used to encrypt Terraform state and lock files."
  value       = aws_kms_key.state.arn
}

output "kms_key_id" {
  description = "KMS key ID for partial S3 backend configuration."
  value       = aws_kms_key.state.key_id
}
