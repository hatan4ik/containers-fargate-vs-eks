#!/usr/bin/env sh
# Read-only local preflight. It never writes AWS resources or Terraform state.
set -eu

usage() {
  cat <<'EOF' >&2
usage: scripts/aws-preflight.sh --environment <fargate-dev|fargate-prod|eks-dev|eks-prod> [--region <aws-region>]

Authenticate first with your MFA-enforced IAM Identity Center profile, for example:
  aws sso login --profile platform-admin
  AWS_PROFILE=platform-admin scripts/aws-preflight.sh --environment fargate-dev --region us-east-1
EOF
  exit 64
}

environment=''
region=''
while [ "$#" -gt 0 ]; do
  case "$1" in
    --environment) environment=${2:-}; shift 2 ;;
    --region) region=${2:-}; shift 2 ;;
    -h | --help) usage ;;
    *) usage ;;
  esac
done

case "$environment" in
  fargate-dev) root="environments/fargate/dev" ;;
  fargate-prod) root="environments/fargate/prod" ;;
  eks-dev) root="environments/eks/dev" ;;
  eks-prod) root="environments/eks/prod" ;;
  *) usage ;;
esac

for command in aws git terraform; do
  if ! command -v "$command" >/dev/null 2>&1; then
    printf '%s\n' "missing required command: $command" >&2
    exit 1
  fi
done

expected_version=$(tr -d '[:space:]' <.terraform-version)
actual_version=$(terraform version | sed -n '1s/^Terraform v//p')
if [ "$actual_version" != "$expected_version" ]; then
  printf '%s\n' "Terraform $expected_version is required; found $actual_version." >&2
  exit 1
fi

if [ -n "$region" ]; then
  account_id=$(aws sts get-caller-identity --region "$region" --query Account --output text)
  principal_arn=$(aws sts get-caller-identity --region "$region" --query Arn --output text)
else
  account_id=$(aws sts get-caller-identity --query Account --output text)
  principal_arn=$(aws sts get-caller-identity --query Arn --output text)
fi

printf '%s\n' "AWS identity verified for account $account_id."
printf '%s\n' "Principal: $principal_arn"
printf '%s\n' "Terraform version: $actual_version"

if [ ! -f "$root/terraform.tfvars" ]; then
  printf '%s\n' "Missing $root/terraform.tfvars; copy and complete its example before planning." >&2
  exit 1
fi

terraform -chdir="$root" init -backend=false -input=false >/dev/null
terraform -chdir="$root" validate >/dev/null
printf '%s\n' "Validated $root without accessing remote state."
printf '%s\n' "Preflight passed. This check cannot prove MFA status; enforce MFA in IAM Identity Center and use a short-lived SSO session."
