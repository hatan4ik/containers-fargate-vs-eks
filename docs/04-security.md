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
- Least privilege IAM roles for tasks/pods
- Private subnets for workloads
- Only public entry via ALB (Fargate) or LB/Ingress (EKS)
