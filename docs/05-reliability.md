# Reliability

Key patterns:

- Timeouts everywhere
- Retries only on safe operations (idempotent)
- Bulkheads and concurrency limits
- Health checks: separate readiness (`/readyz`) vs liveness (`/healthz`)
- Graceful shutdown

The services use `AbortController`-backed timeouts and deliberately do not retry
order creation: a timeout can leave the caller uncertain whether a non-idempotent
order was created. Add durable idempotency keys before introducing retries.

Both infrastructure tracks use two AZs and a NAT gateway per AZ by default.
Fargate deployments roll back automatically when the deployment circuit breaker
trips. Kubernetes uses startup, liveness, and readiness probes plus Pod
Disruption Budgets.

Labs include break/fix scenarios for:

- dependency latency
- bad health checks
- insufficient resources

See [ECS Fargate Track](../labs/10-ecs-fargate-track/README.md) and [EKS Track](../labs/20-eks-track/README.md) for details.
