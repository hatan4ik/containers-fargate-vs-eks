# Terraform security boundaries

Production Terraform is limited to `bootstrap/`, `modules/`, and `environments/`.
Checkov scans those paths in CI; `labs/` is excluded because it contains isolated
teaching examples that deliberately demonstrate non-production trade-offs.

The S3 state bootstrap has versioning, KMS encryption, public-access blocking,
TLS-only access, state locking, and incomplete multipart-upload cleanup. S3-native
locking requires Terraform 1.10 or later. CI uses GitHub OIDC roles; operators use
MFA-backed IAM Identity Center roles.

Workload environment values must supply dedicated KMS keys for CloudWatch Logs
and EKS Secret envelope encryption; do not reuse the state KMS key. ALB access-log
buckets are pre-provisioned platform dependencies and must grant the relevant ALB
log-delivery principal write access.
