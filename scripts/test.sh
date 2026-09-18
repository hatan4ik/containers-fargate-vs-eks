#!/usr/bin/env bash
set -euo pipefail
npm test
kubectl kustomize labs/20-eks-track/k8s/overlays/dev >/dev/null
kubectl kustomize labs/20-eks-track/k8s/overlays/prod >/dev/null
