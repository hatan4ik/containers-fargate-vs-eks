# Prerequisites

## Local
- Docker Desktop
- Node.js 22+
- jq

## AWS + IaC
- AWS account
- Terraform >= 1.6
- AWS CLI v2
- kubectl (for EKS track)
- helm (optional but recommended for EKS addons / Istio)
- eksctl (optional)

## GitHub Actions OIDC
You must create an AWS IAM role that trusts GitHub’s OIDC provider and allows:
- ECR push
- Terraform apply (for infra deploy workflow if you use it)

See `docs/04-security.md`.
