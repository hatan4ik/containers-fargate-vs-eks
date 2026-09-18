# Track A — ECS Fargate (Full)

**PREREQUISITE**: complete `labs/00-setup` before starting this track.

Goal: deploy gateway/users/orders to ECS Fargate behind an ALB.

## Steps

1. Build and push a `sha-<commit-sha>` image set to ECR.
2. Deploy infrastructure via Terraform in `terraform/` using those immutable tags.
3. Validate `/healthz`, `/readyz`, and `/checkout`.
4. Use the runbooks to diagnose or roll back.
