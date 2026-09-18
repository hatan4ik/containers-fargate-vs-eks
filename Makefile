TERRAFORM_MODULES := \
	modules/platform/terraform-state \
	modules/identity/github-actions-oidc \
	modules/network/vpc \
	modules/observability/log-group \
	modules/compute/ecs-cluster \
	modules/compute/ecs-service \
	modules/compute/eks \
	modules/stacks/fargate-platform \
	modules/stacks/eks-platform

TERRAFORM_ROOTS := \
	bootstrap/state-backend \
	environments/fargate/dev \
	environments/fargate/prod \
	environments/eks/dev \
	environments/eks/prod \
	labs/10-ecs-fargate-track/terraform \
	labs/20-eks-track/terraform

TERRAFORM_DOCS ?= terraform-docs
TFLINT_CONFIG ?= $(CURDIR)/.tflint.hcl

.PHONY: terraform-format terraform-lint terraform-validate terraform-test terraform-docs terraform-docs-check terraform-ci

terraform-format:
	terraform fmt -check -recursive

terraform-lint:
	@for directory in $(TERRAFORM_MODULES) $(TERRAFORM_ROOTS); do \
		terraform -chdir=$$directory init -backend=false -input=false >/dev/null; \
		tflint --chdir=$$directory --config=$(TFLINT_CONFIG); \
	done

terraform-validate:
	@for directory in $(TERRAFORM_MODULES) $(TERRAFORM_ROOTS); do \
		terraform -chdir=$$directory init -backend=false -input=false >/dev/null; \
		terraform -chdir=$$directory validate; \
	done

terraform-test:
	@for directory in $(TERRAFORM_MODULES); do \
		terraform -chdir=$$directory test; \
	done

terraform-docs:
	@for directory in $(TERRAFORM_MODULES) bootstrap/state-backend; do \
		$(TERRAFORM_DOCS) --config .terraform-docs.yml $$directory; \
	done

terraform-docs-check: terraform-docs
	git diff --exit-code -- $(addsuffix /README.md,$(TERRAFORM_MODULES)) bootstrap/state-backend/README.md

terraform-ci: terraform-format terraform-lint terraform-validate terraform-test terraform-docs-check
