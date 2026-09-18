#!/usr/bin/env bash
set -euo pipefail
npm run lint
terraform -chdir=labs/10-ecs-fargate-track/terraform fmt -check -recursive
terraform -chdir=labs/20-eks-track/terraform fmt -check -recursive
tflint --chdir=labs/10-ecs-fargate-track/terraform --recursive
tflint --chdir=labs/20-eks-track/terraform --recursive
shellcheck --external-sources scripts/*.sh labs/01-local-containers/scripts/*.sh
