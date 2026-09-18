# Track B — EKS (Full)

**PREREQUISITE**: complete `labs/00-setup` before starting this track.

Goal: provision a private-by-default EKS cluster with Terraform and deploy the
services through a validated Kustomize render.

## Steps

1. Build and push a `sha-<commit-sha>` image set to ECR.
2. Provision EKS: `terraform/`.
3. Configure `kubectl` from a management environment connected to the cluster VPC.
4. Render and deploy manifests with `scripts/deploy.sh`.

See `runbooks/deploy.md`.
