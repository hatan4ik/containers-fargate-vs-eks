#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: IMAGE_REGISTRY=<registry> IMAGE_TAG=sha-<commit-sha> $0 [--dry-run]" >&2
  exit 2
}

image_registry="${IMAGE_REGISTRY:-}"
image_tag="${IMAGE_TAG:-}"
dry_run=false

if [[ "${1:-}" == "--dry-run" ]]; then
  dry_run=true
elif [[ $# -gt 0 ]]; then
  usage
fi

if [[ ! "$image_registry" =~ ^[A-Za-z0-9][A-Za-z0-9./:-]*$ ]] || [[ ! "$image_tag" =~ ^sha-[0-9a-f]{40}$ ]]; then
  usage
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
rendered="$(kubectl kustomize "$script_dir/../k8s/overlays/prod" | sed -e "s|REPLACE_ME|$image_registry|g" -e "s|:main|:$image_tag|g")"

if [[ "$dry_run" == true ]]; then
  printf '%s\n' "$rendered"
  exit 0
fi

printf '%s\n' "$rendered" | kubectl apply -f -
kubectl -n z2h rollout status deployment/users --timeout=3m
kubectl -n z2h rollout status deployment/orders --timeout=3m
kubectl -n z2h rollout status deployment/gateway --timeout=3m
