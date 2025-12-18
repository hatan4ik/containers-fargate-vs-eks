# Deploy (EKS)

## 1) Terraform apply
```bash
cd labs/20-eks-track/terraform
terraform init
terraform apply
```

## 2) Configure kubectl
```bash
REGION=$(terraform output -raw region)
CLUSTER=$(terraform output -raw cluster_name)
aws eks update-kubeconfig --region "$REGION" --name "$CLUSTER"
```

## 3) Deploy services
Edit image references in `k8s/base/deployments.yaml` (REPLACE_ME) or set kustomize overlay.
```bash
kubectl apply -f k8s/base/namespace.yaml
kubectl apply -f k8s/base/configmap.yaml
kubectl apply -f k8s/base/deployments.yaml
```

## 4) Validate
```bash
kubectl -n z2h get svc gateway -w
```
Then curl the LoadBalancer endpoint.

## Optional addons (helm)
See `terraform/` outputs for OIDC + IRSA notes and `docs/04-security.md`.
