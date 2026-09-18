#!/usr/bin/env sh
# Configure non-secret GitHub Environment variables from reviewed bootstrap output.
set -eu

usage() {
  cat <<'EOF' >&2
usage: scripts/configure-github-environments.sh \
  --bootstrap-outputs /safe/path/bootstrap-outputs.json \
  --aws-region <region> --state-region <region> [--repo owner/repository] [--apply]

Create and protect the four GitHub Environments in the GitHub UI first. The script
is dry-run by default and never configures Terraform apply roles.
EOF
  exit 64
}

outputs_file=''
aws_region=''
state_region=''
repository=''
apply=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --bootstrap-outputs) outputs_file=${2:-}; shift 2 ;;
    --aws-region) aws_region=${2:-}; shift 2 ;;
    --state-region) state_region=${2:-}; shift 2 ;;
    --repo) repository=${2:-}; shift 2 ;;
    --apply) apply=1; shift ;;
    -h | --help) usage ;;
    *) usage ;;
  esac
done

if [ -z "$outputs_file" ] || [ -z "$aws_region" ] || [ -z "$state_region" ] || [ ! -f "$outputs_file" ]; then
  usage
fi
for command in gh jq; do
  if ! command -v "$command" >/dev/null 2>&1; then
    printf '%s\n' "missing required command: $command" >&2
    exit 1
  fi
done

if [ -z "$repository" ]; then
  repository=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
fi

state_bucket=$(jq -er '.state_bucket_name.value' "$outputs_file")
state_key_id=$(jq -er '.state_kms_key_id.value' "$outputs_file")

set_variable() {
  environment=$1
  name=$2
  value=$3
  if [ "$apply" -eq 1 ]; then
    gh variable set "$name" --repo "$repository" --env "$environment" --body "$value"
  else
    printf '%s\n' "would set $name in GitHub Environment $environment"
  fi
}

for environment in fargate-dev fargate-prod eks-dev eks-prod; do
  gh api "repos/$repository/environments/$environment" --silent
  plan_role=$(jq -er --arg environment "$environment" '.plan_role_arns.value[$environment]' "$outputs_file")
  set_variable "$environment" AWS_REGION "$aws_region"
  set_variable "$environment" TF_STATE_BUCKET "$state_bucket"
  set_variable "$environment" TF_STATE_KMS_KEY_ID "$state_key_id"
  set_variable "$environment" TF_STATE_REGION "$state_region"
  set_variable "$environment" TERRAFORM_PLAN_ROLE_ARN "$plan_role"
done

if [ "$apply" -eq 1 ]; then
  printf '%s\n' "Configured plan-only variables. Add ECR variables and apply roles only after their independent least-privilege review."
else
  printf '%s\n' "Dry run passed. Re-run with --apply only after confirming Environment approval protections."
fi
