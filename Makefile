TERRAFORM_MODULES := \
	modules/platform/terraform-state \
	modules/identity/github-actions-oidc \
	modules/identity/external-ci-oidc \
	modules/network/vpc \
	modules/observability/log-group \
	modules/compute/ecs-cluster \
	modules/compute/ecs-service \
	modules/compute/eks \
	modules/stacks/fargate-platform \
	modules/stacks/eks-platform

TERRAFORM_ROOTS := \
	bootstrap/state-backend \
	bootstrap/external-ci-oidc \
	environments/fargate/dev \
	environments/fargate/prod \
	environments/eks/dev \
	environments/eks/prod \
	labs/10-ecs-fargate-track/terraform \
	labs/20-eks-track/terraform

# Keep generated documentation byte-for-byte identical in local development and CI.
TERRAFORM_DOCS ?= docker run --rm -v $(CURDIR):/work -w /work quay.io/terraform-docs/terraform-docs:0.20.0
TFLINT_CONFIG ?= $(CURDIR)/.tflint.hcl
TERRAFORM_LOCK_PLATFORMS ?= -platform=darwin_amd64 -platform=linux_amd64

.PHONY: terraform-format terraform-lint terraform-validate terraform-test terraform-lock terraform-docs terraform-docs-check terraform-ci

terraform-format:
	@for directory in $$(git ls-files '*.tf' '*.tfvars' '*.tftest.hcl' | xargs -n1 dirname | sort -u); do \
		terraform -chdir=$$directory fmt -check; \
	done

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

terraform-lock:
	@for directory in $(TERRAFORM_MODULES) $(TERRAFORM_ROOTS); do \
		terraform -chdir=$$directory providers lock $(TERRAFORM_LOCK_PLATFORMS); \
	done

terraform-docs:
	@for directory in $(TERRAFORM_MODULES) bootstrap/state-backend; do \
		$(TERRAFORM_DOCS) --config .terraform-docs.yml $$directory; \
	done

terraform-docs-check: terraform-docs
	git diff --exit-code -- $(addsuffix /README.md,$(TERRAFORM_MODULES)) bootstrap/state-backend/README.md

terraform-ci: terraform-format terraform-lint terraform-validate terraform-test terraform-docs-check
