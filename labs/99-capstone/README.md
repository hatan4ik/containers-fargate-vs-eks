# Capstone — Production Baseline

Deliver either track with:

- Timeouts everywhere, retries only where safe (no retry of a non-idempotent order)
- Request-ID propagation across gateway, orders, and users
- Private internal services (only entry via ALB/LB)
- Autoscaling (Fargate includes gateway CPU autoscaling; add an approved metrics
  pipeline before introducing EKS HPA)
- Runbooks executed at least once (deploy + rollback + debug)
