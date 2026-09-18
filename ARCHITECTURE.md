# Terraform architecture and operating model

## Layout

```text
bootstrap/state-backend/    one-time secure state and GitHub Actions OIDC bootstrap
bootstrap/external-ci-oidc/ optional GitLab/Azure DevOps OIDC bootstrap
modules/<domain>/<unit>/    reusable, provider-agnostic building blocks
modules/stacks/             cohesive Fargate and EKS compositions
environments/<platform>/<env>/
                            roots: providers, remote-state declaration, one stack call
labs/                       isolated teaching material; never deployed as production roots
```

An environment root contains no `resource` blocks. It selects exactly one immutable
stack module revision, supplies its typed inputs, and exposes only operationally
useful outputs. Modules do not configure providers or read another module's state.
Values flow through explicit module inputs and outputs.

## Configuration contract

- `variables.tf` is the public type contract. Inputs use concrete Terraform types,
  descriptions, nullability, and validation where invalid values could reach AWS.
- `terraform.tfvars.example` is committed as the schema-shaped starting point.
  Copy it to the ignored `terraform.tfvars` for real environment values; do not
  commit account IDs, certificate ARNs, state locations, or security destinations.
- `locals.tf` derives names and merges caller tags with non-overridable module tags.
  Required governance tags are validated at the environment boundary.
- Resources with repeated instances are driven by maps and stable `for_each` keys,
  never positional list indexes.

CI YAML orchestrates credentials and checks only. It does not duplicate Terraform
environment values. The active GitHub manual plan workflow selects one allowlisted
protected Environment, obtains its OIDC plan role, decodes its Environment-scoped
`TERRAFORM_TFVARS_B64` only for the run, and initializes encrypted S3 state with
native locking. GitLab and Azure DevOps use the same plan helper but are opt-in,
manual-by-default alternatives, not additional authorities for the same target.

## Adding infrastructure

To add another instance supported by an existing collection module, add one stable
keyed entry to that environment's `terraform.tfvars` and run the plan workflow. For a
new cohesive resource group, create `modules/<domain>/<unit>` with:

1. `main.tf`, `locals.tf`, `variables.tf`, `outputs.tf`, and `versions.tf`.
2. Typed inputs, validation, required-tag enforcement, and no provider blocks.
3. Minimal and complete examples plus plan-only Terraform tests, including a rejected
   invalid value.
4. A generated README: `make terraform-docs`.

Add a single version-pinned module call to the relevant stack or environment root;
never copy a resource block between environments.

## Adding an environment

1. Copy the closest environment root and assign an independent S3 state key.
2. Add an approved GitHub Environment, required reviewers for production, and only
   its scoped `TF_STATE_*`, `TERRAFORM_PLAN_ROLE_ARN`, `TERRAFORM_TFVARS_B64`, and
   release variables.
3. Add a matching environment-scoped OIDC role with least-privilege policies.
4. Create ignored `terraform.tfvars` from the example, run a plan, and review it.
   An apply requires a separate, explicit approval and a migration-safe zero-change
   baseline.

## Release and migration policy

Module releases use annotated semantic-version tags such as `modules-v1.3.0`.
Environment sources are pinned to the corresponding immutable Git commit SHA; tags
are the human release label, while the SHA prevents a tag move from changing an
environment. Update a root only in a reviewed pull request with a plan.

Never infer Terraform `moved` addresses. Before a refactor of live state, capture the
current state inventory and baseline plan, add reviewed `moved` blocks, and prove the
post-refactor plan has no unintended create, change, destroy, or replace operations.
No workflow in this repository applies Terraform automatically.

## Quality gates

`make terraform-ci` checks formatting, initializes and lints every root/module,
validates them, runs native Terraform plan tests, and verifies generated docs. The
provider locks contain macOS and Linux checksums; run `make terraform-lock` after an
intentional provider upgrade. CI also performs JavaScript formatting/type checks,
service tests, Docker builds, and Checkov policy scans.

The state backend, OIDC boundary, security assumptions, and complete bootstrap
procedure are documented in [docs/terraform-security.md](docs/terraform-security.md)
and [docs/AWS_SETUP.md](docs/AWS_SETUP.md).
