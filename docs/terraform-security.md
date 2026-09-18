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

ECR publishing is a separate release concern. The publish workflow runs only for
`service-v*` tags or manual dispatch, requires a protected `fargate-*` GitHub
Environment, and uses its `ECR_PUBLISH_ROLE_ARN` through OIDC. That role must allow
only the required ECR push actions on the three pre-provisioned repositories; CI
never creates repositories or uses a Terraform apply role to publish images.

The state bootstrap additionally requires a dedicated S3 access-log destination,
a versioned cross-region replica bucket and replica KMS key, and its account-root
principal ARN. It enables EventBridge notifications for state-bucket audit events.
The only Checkov waivers are KMS-policy checks that require `Resource: "*"` by AWS
design; their principals are explicitly constrained in the key policy. This exception
must be reviewed by 2027-09-18 and removed when the scanner can model that AWS KMS
requirement without a wildcard-resource finding.
