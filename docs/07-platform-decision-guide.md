# Platform Decision Guide: ECS Fargate vs EKS

Choose **ECS Fargate** when:
- You value speed and simplicity
- You want minimal platform ops
- REST + events are your main comms model

Choose **EKS** when:
- You need Kubernetes ecosystem + mesh
- You run many services / teams
- You need advanced rollouts and traffic policies

Scorecard (0-2 each):
1) Need service mesh advanced routing now?
2) Dedicated platform team exists?
3) Need portability?
4) > 50 services?
5) Need custom operators/CRDs?
>= 6 → EKS likely justified, else Fargate.
