# Acceptance Tests

## Local

- [ ] `./scripts/lint.sh` and `./scripts/test.sh` pass
- [ ] `POST /checkout` returns 201 and returns an `x-request-id`
- [ ] Invalid JSON returns 400; unavailable dependencies return 502 or 504 without leaking their body

## ECS Fargate

- [ ] ALB serves `/healthz`
- [ ] ALB serves `/readyz`
- [ ] `/checkout` works end-to-end
- [ ] CloudWatch logs show request IDs
- [ ] VPC flow logs have no unexpected rejected gateway → orders or orders → users traffic

## EKS

- [ ] `gateway` Service LB reachable
- [ ] `/checkout` works end-to-end
- [ ] Pods are Ready and run as non-root with a read-only filesystem
- [ ] NetworkPolicies allow only the required internal service calls
- [ ] Rollback tested with `kubectl rollout undo`
