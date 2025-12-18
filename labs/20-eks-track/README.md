# Track B — EKS (Full)

**PREREQUISITE**: complete `labs/00-setup` before starting this track.

Goal: provision EKS via Terraform, deploy services via K8s manifests, and (optional) install Istio.

## Steps
1) Build + push images to ECR
2) Provision EKS: `terraform/`
3) Configure kubectl (terraform outputs show cluster name/region)
4) Deploy manifests: `k8s/base`
5) Optional: install addons via Helm (metrics-server, ALB controller, Istio)

See `runbooks/deploy.md`.
