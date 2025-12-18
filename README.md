# Containers, Service Communication, ECS Fargate vs EKS

Production-grade, O’Reilly-style learning repo for:
- Containerized services that communicate (REST, gRPC, events)
- **Track A:** AWS **ECS Fargate**
- **Track B:** AWS **EKS (Kubernetes)**
- CI/CD to **ECR** using **GitHub Actions OIDC (no static AWS keys)**
- Optional **Service Mesh (Istio)** for advanced traffic management

## Quick start (local)
```bash
cd labs/01-local-containers
./scripts/up.sh
./scripts/smoke.sh
```

## Services
This repo contains three simple Node.js (Express) services:
- `gateway`: API gateway that exposes a `/checkout` endpoint and forwards requests to the `orders` service.
- `users`: Returns user information.
- `orders`: Creates orders and calls the `users` service to get user information.

## Tracks
- Track A (Fargate): `labs/10-ecs-fargate-track`
- Track B (EKS): `labs/20-eks-track`
- Capstone: `labs/99-capstone`

## Prerequisites
See `labs/00-setup/prerequisites.md`.

## CI/CD (OIDC)
See `docs/04-security.md` and `.github/workflows/*` for setup:
- Configure AWS IAM Role trust for GitHub OIDC
- Set repo variables: `AWS_REGION`, `AWS_ROLE_ARN`, `ECR_REGISTRY`
- Images will be pushed to ECR for: `gateway`, `users`, `orders`

## Service Mesh (optional)
Phase 6: `docs/02-service-communication.md#phase-6-service-mesh-istio-optional`

## License
MIT
