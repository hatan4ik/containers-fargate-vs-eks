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
