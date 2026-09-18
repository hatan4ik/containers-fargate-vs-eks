# Deploy (EKS)

## 1) Terraform apply

```bash
cd labs/20-eks-track/terraform
terraform init
terraform apply
```

The API endpoint is private by default. Run the remaining commands from a host
with network access to the VPC (for example, a VPN-connected workstation or a
self-hosted CI runner). To deliberately expose the management endpoint, set both
`endpoint_public_access=true` and a narrow `endpoint_public_access_cidrs` list.

## 2) Configure kubectl

```bash
REGION=$(terraform output -raw region)
CLUSTER=$(terraform output -raw cluster_name)
aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER"
```

## 3) Deploy services

Deploy an immutable image tag. The script validates the registry and tag, renders
Kustomize without changing tracked manifests, applies it, and waits for all
rollouts.

```bash
IMAGE_REGISTRY=123456789012.dkr.ecr.us-east-1.amazonaws.com \
IMAGE_TAG=sha-<commit-sha> \
./scripts/deploy.sh
```

## 4) Validate

```bash
kubectl -n z2h get svc gateway -w
```

Then curl the LoadBalancer endpoint.

The base includes non-root pod security, probes, resource limits, disruption
budgets, and NetworkPolicies. The Terraform EKS VPC CNI configuration enables
NetworkPolicy enforcement.
