# Cost / FinOps

What to measure:

- Cost per request / per customer journey
- Idle capacity vs burst needs
- NAT and data transfer costs
- Logging retention costs

The default topology uses one NAT gateway per AZ to avoid an AZ-level egress
single point of failure. For a cost-focused non-production lab, set
`single_nat_gateway=true`; this intentionally trades availability for cost.

Fargate: pay for CPU/memory while running
EKS: control node costs; can optimize heavily but more complex
