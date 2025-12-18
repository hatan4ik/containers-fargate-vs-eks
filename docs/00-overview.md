# Overview

You’re learning two things in parallel:

1) **Service communication**
- Sync: REST, gRPC
- Async: events/queues
- Timeouts, retries, backpressure, idempotency

2) **Platform choice**
- ECS Fargate: ship fast, minimal ops
- EKS: maximum control, higher ops tax

Rule of thumb:
- Start with Fargate for product delivery.
- Use EKS when you need platform control/mesh/scale and can pay the ops tax.
