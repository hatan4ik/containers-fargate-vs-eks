# Track A — ECS Fargate (Full)

**PREREQUISITE**: complete `labs/00-setup` before starting this track.

Goal: deploy gateway/users/orders to ECS Fargate behind an ALB.

## Steps
1) Build + push images to ECR (CI or manual)
2) Deploy infra via Terraform in `terraform/`
3) Validate with `/healthz` and `/checkout`
4) Break/fix using runbooks
