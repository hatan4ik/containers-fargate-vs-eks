#!/usr/bin/env bash
set -euo pipefail
npm run format
terraform -chdir=labs/10-ecs-fargate-track/terraform fmt -recursive
terraform -chdir=labs/20-eks-track/terraform fmt -recursive
