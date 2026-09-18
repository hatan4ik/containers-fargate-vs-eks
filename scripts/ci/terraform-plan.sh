#!/usr/bin/env sh
# Produce a non-sensitive, no-apply plan from a CI environment's protected config.
set -eu

usage() {
  printf '%s\n' "usage: $0 <fargate-dev|fargate-prod|eks-dev|eks-prod>" >&2
  exit 64
}

target=${1:-}
case "$target" in
  fargate-dev) root="environments/fargate/dev" ;;
  fargate-prod) root="environments/fargate/prod" ;;
  eks-dev) root="environments/eks/dev" ;;
  eks-prod) root="environments/eks/prod" ;;
  *) usage ;;
esac

: "${TF_STATE_BUCKET:?TF_STATE_BUCKET must be supplied by the protected CI environment}"
: "${TF_STATE_KMS_KEY_ID:?TF_STATE_KMS_KEY_ID must be supplied by the protected CI environment}"
: "${TF_STATE_REGION:?TF_STATE_REGION must be supplied by the protected CI environment}"

tfvars_path="$root/terraform.tfvars"
plan_path="$root/tfplan"
plan_json_path="$root/tfplan.json"
generated_tfvars=0

cleanup() {
  rm -f "$plan_path" "$plan_json_path"
  if [ "$generated_tfvars" -eq 1 ]; then
    rm -f "$tfvars_path"
  fi
}
trap cleanup EXIT HUP INT TERM

if [ -n "${TERRAFORM_TFVARS_B64:-}" ]; then
  umask 077
  generated_tfvars=1
  if ! printf '%s' "$TERRAFORM_TFVARS_B64" | base64 --decode >"$tfvars_path" 2>/dev/null; then
    printf '%s' "$TERRAFORM_TFVARS_B64" | base64 -d >"$tfvars_path"
  fi
elif [ ! -f "$tfvars_path" ]; then
  printf '%s\n' "TERRAFORM_TFVARS_B64 is required in CI; it is decoded only for this plan." >&2
  exit 1
fi

terraform -chdir="$root" init -input=false -reconfigure \
  -backend-config="bucket=$TF_STATE_BUCKET" \
  -backend-config="region=$TF_STATE_REGION" \
  -backend-config="kms_key_id=$TF_STATE_KMS_KEY_ID" \
  -backend-config="encrypt=true" \
  -backend-config="use_lockfile=true" >/dev/null
terraform -chdir="$root" validate >/dev/null

set +e
terraform -chdir="$root" plan -input=false -no-color -lock-timeout=5m -detailed-exitcode \
  -out=tfplan -var-file=terraform.tfvars >/dev/null
plan_status=$?
set -e

case "$plan_status" in
  0 | 2) ;;
  *) exit "$plan_status" ;;
esac

terraform -chdir="$root" show -json tfplan >"$plan_json_path"

if [ -n "${GITHUB_STEP_SUMMARY:-}" ] && command -v jq >/dev/null 2>&1; then
  {
    printf '%s\n\n' "## Terraform plan: $target"
    printf '%s\n' "| Action | Count |" "| --- | ---: |"
    jq -r '
      [ .resource_changes[]?.change.actions[] ]
      | group_by(.)
      | map({action: .[0], count: length})
      | .[]
      | "| \(.action) | \(.count) |"
    ' "$plan_json_path"
  } >>"$GITHUB_STEP_SUMMARY"
fi

printf '%s\n' "Terraform plan completed for $target (detailed exit code: $plan_status)."
