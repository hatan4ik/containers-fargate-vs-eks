# Fargate development environment

This root contains one immutable platform-module call. Terraform 1.10+ is
required for native S3 state locking. Copy the example files outside source
control, supply approved values (including separate CloudWatch KMS keys and an
ALB access-log bucket), and run a plan with the development GitHub Environment
OIDC plan role. No moved block belongs here until the current state and a
successful baseline plan are available.
