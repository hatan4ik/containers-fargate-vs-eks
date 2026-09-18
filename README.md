# Containers, Service Communication, ECS Fargate vs EKS

Production-grade learning repo for:

- Containerized services that communicate (REST, gRPC, events)
- **Track A:** AWS **ECS Fargate**
- **Track B:** AWS **EKS (Kubernetes)**
- CI/CD to **ECR** using **GitHub Actions OIDC (no static AWS keys)** and immutable commit tags
- Optional **Service Mesh (Istio)** for advanced traffic management

## Quick start (local)

```bash
cd labs/01-local-containers
./scripts/up.sh
./scripts/smoke.sh
```

## Services

This repo contains three Node.js (Express) services. Each service has validated
configuration, bounded dependency calls, JSON request/response contracts,
structured request-ID-aware logs, graceful shutdown, and unit tests:

- `gateway`: API gateway that exposes a `/checkout` endpoint and forwards requests to the `orders` service.
- `users`: Returns user information.
- `orders`: Creates orders and calls the `users` service to get user information.

## Tracks

- Track A (Fargate): `labs/10-ecs-fargate-track`
- Track B (EKS): `labs/20-eks-track`
- Capstone: `labs/99-capstone`

## Prerequisites

See `labs/00-setup/prerequisites.md`.

For the complete production AWS path—external prerequisites, secure state
bootstrap, OIDC CI configuration, and a first reviewed plan—follow
[docs/AWS_SETUP.md](docs/AWS_SETUP.md).

## CI/CD (OIDC)

See [docs/AWS_SETUP.md](docs/AWS_SETUP.md), `docs/04-security.md`, and
`.github/workflows/*` for setup:

- Bootstrap encrypted S3 state and use protected GitHub Environments with
  OIDC-only plan roles; CI never stores AWS access keys.
- GitLab and Azure DevOps have equivalent, manual-by-default OIDC pipeline
  templates for intentionally separate CI authorities.
- Images are pushed to ECR for `gateway`, `users`, and `orders` with an immutable
  `sha-<commit-sha>` tag. Publishing runs only for `service-v*` release tags or a
  manual dispatch through an approved GitHub Environment. Use that exact tag or an
  image digest for deployments.

## Verification

```bash
npm ci
./scripts/lint.sh
./scripts/test.sh
```

The CI workflow runs the same checks, Terraform validation, Kubernetes rendering,
and container builds before an image can be published.

When intentionally upgrading a provider, regenerate the committed cross-platform
dependency locks before opening the PR:

```bash
make terraform-lock
```

## Service Mesh (optional)

Phase 6: `docs/02-service-communication.md#phase-6-service-mesh-istio-optional`

## License

MIT
