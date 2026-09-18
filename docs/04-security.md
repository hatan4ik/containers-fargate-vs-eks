# Security

## No static secrets in CI

This repo uses **GitHub Actions OIDC** to assume an AWS role.

### Required GitHub repo variables/secrets

**Variables**

- `AWS_REGION` (e.g., us-east-1)
- `ECR_REGISTRY` (e.g., 123456789012.dkr.ecr.us-east-1.amazonaws.com)

**Secrets**

- `AWS_ROLE_ARN` (role that trusts GitHub OIDC)
  - You can put it as a Secret or Variable. This repo expects it as a secret.

## Runtime security

- ECS tasks are in private subnets. Security groups permit only ALB → gateway →
  orders → users; task egress is limited to dependencies, DNS, and HTTPS for
  AWS control-plane services.
- EKS workloads run non-root with a read-only filesystem, no Linux capabilities,
  resource limits, and NetworkPolicies. The EKS VPC CNI is configured to enforce
  those policies.
- The EKS API is private by default. If a public management endpoint is needed,
  set `endpoint_public_access=true` and provide an explicit CIDR allow list.
- ECS Exec is enabled for incident response. Its task role has only the required
  `ssmmessages` permissions; operator IAM access remains an account-level
  prerequisite.
