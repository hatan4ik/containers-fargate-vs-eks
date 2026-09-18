# Terraform security boundaries

Production Terraform is limited to `bootstrap/`, `modules/`, and `environments/`.
Checkov scans those paths in CI; `labs/` is excluded because it contains isolated
teaching examples that deliberately demonstrate non-production trade-offs.

The S3 state bootstrap has versioning, KMS encryption, public-access blocking,
TLS-only access, state locking, and incomplete multipart-upload cleanup. CI uses
GitHub OIDC roles; operators use MFA-backed IAM Identity Center roles.
