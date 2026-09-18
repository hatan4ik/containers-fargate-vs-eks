# EKS development environment

This root contains one immutable platform-module call. Terraform 1.10+ is
required for native S3 state locking. Copy the example files outside source
control, supply distinct KMS keys for flow logs, control-plane logs, and
Kubernetes Secrets, then run a plan with the development GitHub Environment OIDC
plan role. No moved block belongs here until current state and a successful
baseline plan are available.
