# Debug (ECS Fargate)

Checklist:

- Target group health check path = /healthz
- Security groups must retain the exact call graph: ALB → gateway (3000) → orders
  (3002) → users (3001). Check VPC flow logs for rejected traffic.
- Tasks in private subnets with NAT egress
- CloudWatch logs show app started and binds correct PORT
