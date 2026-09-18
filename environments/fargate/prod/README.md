# Fargate production environment

This root contains one immutable platform-module call. GitHub Environment
protection, the production OIDC role, Terraform 1.10+ native S3 locking, a
reviewed plan, and exact state moves are mandatory before any apply. The example
requires TLS, encrypted logs, ALB access logging, and does not permit broad
internet ingress or egress.
