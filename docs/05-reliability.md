# Reliability

Key patterns:
- Timeouts everywhere
- Retries only on safe operations (idempotent)
- Bulkheads and concurrency limits
- Health checks: readiness vs liveness
- Graceful shutdown

Labs include break/fix scenarios for:
- dependency latency
- bad health checks
- insufficient resources

See [ECS Fargate Track](../labs/10-ecs-fargate-track/README.md) and [EKS Track](../labs/20-eks-track/README.md) for details.
