# Debug (ECS Fargate)

Checklist:
- Target group health check path = /healthz
- SG: ALB ingress 80 from 0.0.0.0/0; service ingress from ALB SG
- Tasks in private subnets with NAT egress
- CloudWatch logs show app started and binds correct PORT
