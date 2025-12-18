# Capstone — Production Baseline

Deliver either track with:
- Timeouts everywhere, retries only where safe
- Request ID propagation (done at gateway)
- Private services (only entry via ALB/LB)
- Autoscaling (Fargate module includes gateway CPU autoscaling; EKS includes metrics-server for HPA extension)
- Runbooks executed at least once (deploy + rollback + debug)
