# Observability

Minimum production baseline:

- Structured logs (JSON)
- Request-ID propagation at every service boundary (`x-request-id`)
- RED metrics (Rate, Errors, Duration)
- Dashboards + alerting on error rate and latency

This repo logs one request ID from the gateway through `orders` to `users` and
returns it to the caller. Both tracks also enable bounded CloudWatch log
retention; VPC flow logs capture accepted and rejected network flows.

Track A: CloudWatch logs/alarms
Track B: CloudWatch Container Insights or Prometheus stack (optional)
