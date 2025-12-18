# Acceptance Tests

## Local
- [ ] `POST /checkout` returns 201

## ECS Fargate
- [ ] ALB serves `/healthz`
- [ ] `/checkout` works end-to-end
- [ ] CloudWatch logs show request IDs

## EKS
- [ ] `gateway` Service LB reachable
- [ ] `/checkout` works end-to-end
- [ ] Rollback tested with `kubectl rollout undo`
