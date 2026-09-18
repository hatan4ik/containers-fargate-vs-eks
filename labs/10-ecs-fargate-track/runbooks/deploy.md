# Deploy (ECS Fargate)

## 1) Push images to ECR

Use GitHub Actions workflow `build_push_ecr.yml` (recommended) or do it manually.

## 2) Terraform apply

```bash
cd labs/10-ecs-fargate-track/terraform
terraform init
terraform apply \
  -var 'image_gateway=ECR_REGISTRY/gateway:sha-<commit-sha>' \
  -var 'image_users=ECR_REGISTRY/users:sha-<commit-sha>' \
  -var 'image_orders=ECR_REGISTRY/orders:sha-<commit-sha>'
```

## 3) Validate

Terraform outputs `alb_dns_name`.

```bash
ALB=$(terraform output -raw alb_dns_name)
curl -s "http://$ALB/healthz" | jq
curl -s "http://$ALB/readyz" | jq
curl -s -X POST "http://$ALB/checkout" -H 'content-type: application/json'   -d '{"userId":"123","item":"demo"}' | jq
```
