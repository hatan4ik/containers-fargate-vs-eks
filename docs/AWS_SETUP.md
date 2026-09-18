# AWS platform setup: from zero to a reviewed plan

This runbook establishes the AWS prerequisites, encrypted Terraform state, OIDC
CI identity, and a first no-apply plan for the Fargate or EKS environment roots.
It deliberately does **not** automate a Terraform apply. A human with a
short-lived, MFA-backed IAM Identity Center session reviews every state-changing
plan and approves any separate deployment process.

Use GitHub Actions as the active CI authority. The GitLab and Azure DevOps files
in the repository are optional, manually triggered equivalents for a mirrored
repository; choose one CI authority for a target AWS account and environment.

## 1. Operator workstation and access

Install the exact Terraform version in `.terraform-version`, AWS CLI v2, Git,
GitHub CLI, `jq`, and Docker (Docker is required only for the full local quality
gate). Authenticate with IAM Identity Center under an MFA-enforced permission
set; do not create IAM users or long-lived access keys.

```bash
aws sso login --profile platform-admin
AWS_PROFILE=platform-admin \
  scripts/aws-preflight.sh --environment fargate-dev --region us-east-1
```

The preflight makes only `sts:GetCallerIdentity` calls and performs a local
backend-free Terraform validation. It confirms the selected identity and tool
version, but MFA enforcement belongs in IAM Identity Center and cannot be proven
by an AWS API call.

## 2. Supply the intentional external dependencies

These are account/platform dependencies, rather than hidden Terraform side
effects. Record their ARNs in the appropriate ignored `terraform.tfvars` file
only after their policies have been reviewed.

| Dependency                  | Required property before a workload plan                                                                                                        |
| --------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| State access-log bucket     | Separate S3 bucket with Block Public Access, lifecycle policy, and server-access-log delivery write policy.                                     |
| State DR bucket and KMS key | Versioned bucket and customer-managed KMS key in the replica region; their policies permit replication from the state account.                  |
| CloudWatch and EKS KMS keys | Separate customer-managed keys for workload logs and Kubernetes secret envelope encryption; never reuse the Terraform-state key.                |
| ALB log bucket              | Dedicated bucket with the AWS ALB log-delivery principal permitted to write only the approved prefix.                                           |
| WAF delivery                | Kinesis Data Firehose and its destination configured for the required `aws-waf-logs-` prefix if WAF logging is enabled.                         |
| TLS certificate             | Issued ACM certificate in the load balancer region, including validated DNS ownership.                                                          |
| ECR repositories            | `gateway`, `users`, and `orders`, with immutable tags, scan-on-push, and lifecycle policy. CI may push images but does not create repositories. |
| Least-privilege policies    | One reviewed plan policy per environment, and separately reviewed apply and ECR-publish policies. No CI role receives administrator access.     |

The existing environment examples enumerate all typed input values. Keep real
`terraform.tfvars`, backend configuration, rendered plans, and bootstrap output
outside Git; these paths are ignored by the repository.

## 3. Bootstrap encrypted remote state

Prepare a local, ignored configuration from the example. Names and policies below
are illustrative; substitute reviewed account-specific values.

```bash
cd bootstrap/state-backend
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars: bucket names, replica/KMS ARNs, account root, tags,
# and the four approved environment policy ARN sets.
terraform init
terraform plan -out=bootstrap.tfplan
terraform show bootstrap.tfplan
```

After an authorized reviewer has approved the output, run the bootstrap apply
from the MFA/SSO session using the normal Terraform approval prompt. Then capture
the non-secret outputs outside the repository:

```bash
terraform output -json > /safe/path/bootstrap-outputs.json
```

The bootstrap creates an encrypted versioned state bucket with S3 lockfiles, a
dedicated state KMS key, and environment-specific GitHub OIDC plan/apply roles.
It requires the pre-provisioned access-log and disaster-recovery destinations in
the preceding table.

For a pre-existing local backend, take an encrypted backup of the current state,
review its resource inventory, and run `terraform init -migrate-state` with a
backend file stored outside Git. Require a no-change remote-state plan before
enabling an apply role. Never rewrite or force-unlock production state as part of
this procedure.

## 4. Configure GitHub Actions (active authority)

Create these GitHub Environments first: `fargate-dev`, `fargate-prod`, `eks-dev`,
and `eks-prod`. Require reviewers for production and restrict which branches or
tags can access each environment. The existing state bootstrap trust policies
bind each plan role to its exact GitHub repository and Environment subject.

Preview then set the non-secret plan variables from the reviewed bootstrap output:

```bash
scripts/configure-github-environments.sh \
  --bootstrap-outputs /safe/path/bootstrap-outputs.json \
  --aws-region us-east-1 --state-region us-east-1 \
  --repo hatan4ik/containers-fargate-vs-eks

# Re-run only after confirming the Environment protections above.
scripts/configure-github-environments.sh \
  --bootstrap-outputs /safe/path/bootstrap-outputs.json \
  --aws-region us-east-1 --state-region us-east-1 \
  --repo hatan4ik/containers-fargate-vs-eks --apply
```

For every Environment, set these variables: `AWS_REGION`, `TF_STATE_BUCKET`,
`TF_STATE_KMS_KEY_ID`, `TF_STATE_REGION`, and `TERRAFORM_PLAN_ROLE_ARN`. Add
`TERRAFORM_TFVARS_B64` as an Environment **secret**: it is the base64 encoding of
that root's reviewed `terraform.tfvars`, decoded only in the plan job and removed
on exit. On a trusted workstation, set it without printing it:

```bash
base64 < environments/fargate/dev/terraform.tfvars | tr -d '\n' \
  | gh secret set TERRAFORM_TFVARS_B64 \
      --repo hatan4ik/containers-fargate-vs-eks --env fargate-dev
```

For the `fargate-*` Environments only, also add the reviewed `ECR_REGISTRY` and
`ECR_PUBLISH_ROLE_ARN` variables. The ECR publish role must be distinct from the
Terraform plan/apply roles and limited to pushing the three named repositories.

Run **Terraform Plan (manual)** from the Actions tab, select the protected
Environment, and review its non-sensitive summary. It uses GitHub OIDC and cannot
apply Terraform. Retrieve module sources with the pinned commit in each root; do
not replace those SHAs with a floating branch.

## 5. Optional GitLab CI/CD authority

`.gitlab-ci.yml` is a manual/tag-only template. Configure it only for a GitLab
mirror that is intentionally allowed to manage a separate target environment.
Protect the GitLab environment and its variables, then scope all values below to
that environment:

- `AWS_REGION`, `TF_STATE_BUCKET`, `TF_STATE_KMS_KEY_ID`, `TF_STATE_REGION`
- `TERRAFORM_TFVARS_B64` (masked/protected secret)
- `AWS_TERRAFORM_PLAN_ROLE_ARN`
- for `fargate-prod` publishing: `ECR_REGISTRY` and
  `AWS_ECR_PUBLISH_ROLE_ARN`

Use GitLab `id_tokens` with audience `sts.amazonaws.com`; do not use deprecated
job JWT variables. Create the issuer/provider and exact role subjects through
`bootstrap/external-ci-oidc`. For GitLab.com, use issuer `https://gitlab.com`, a
currently verified TLS certificate SHA-1 thumbprint, and an exact `sub` claim such
as `project_path:group/project:environment:fargate-dev`. Bind at least the
immutable GitLab project ID and protected-reference claim as additional exact
conditions. Verify the current GitLab OIDC claim format before each provider
change in the [GitLab AWS OIDC documentation](https://docs.gitlab.com/ci/cloud_services/aws/).

Start a pipeline from the GitLab UI and select one allowlisted target. Its
Terraform job plans only; its image-publish job is additionally limited to a
`service-v*` tag and the protected `fargate-prod` environment.

## 6. Optional Azure DevOps authority

`azure-pipelines.yml` is opt-in (`trigger: none`, `pr: none`). Install the
Terraform extension that supplies `TerraformInstaller@1` and the AWS Toolkit for
Azure DevOps. Create Azure Environments matching the four Terraform targets and
require approvals/checks for production.

For each plan environment, create an AWS Toolkit service connection with **Use
OIDC** selected and the exact connection name used by the YAML, for example
`aws-terraform-plan-fargate-dev`. AWS's Azure DevOps integration uses issuer
`https://vstoken.dev.azure.com/<organization-guid>`, audience
`api://AzureADTokenExchange`, and a service-connection subject in the form
`sc://<organization>/<project>/<service-connection>`. Model those exact values in
`bootstrap/external-ci-oidc/terraform.tfvars`; never broaden a role to every
service connection in an organization. The AWS Toolkit's documented OIDC setup
and the private-EKS deployment pattern are the authoritative references:
[AWS Toolkit for Azure DevOps](https://github.com/aws/aws-toolkit-azure-devops)
and [AWS Prescriptive Guidance](https://docs.aws.amazon.com/prescriptive-guidance/latest/patterns/deploy-workloads-from-azure-devops-pipelines-to-private-amazon-eks-clusters.html).

Create a protected Azure variable group with `AWS_REGION`, `TF_STATE_BUCKET`,
`TF_STATE_KMS_KEY_ID`, `TF_STATE_REGION`, and secret `TERRAFORM_TFVARS_B64`, then
authorize it only for this pipeline. Add `ECR_REGISTRY` only to the independent
protected publish connection. Queue the pipeline manually with
`publishImages=false` for the first plan. Publishing requires both an explicit
`fargate-prod` selection and `publishImages=true`.

## 7. First-plan acceptance and ongoing operation

1. Run `npm ci && ./scripts/lint.sh && ./scripts/test.sh && make terraform-ci`
   locally when Docker is available, or at least `make terraform-ci` before a
   Terraform change.
2. Run the protected CI plan and verify the target, account, backend key, and the
   create/change/destroy counts. Reject unexpected replacements or destroys.
3. Save the approved plan evidence with the pull request or change record. An
   approved plan is not an authorization to re-run against changed source.
4. Keep Terraform apply in a separate, explicitly approved operational process.
   Re-plan after every source, provider, policy, or identity change.
5. Re-run `make terraform-lock` whenever intentionally upgrading providers and
   review the cross-platform lock-file diff.

Use OIDC for CI and MFA-backed short-lived IAM Identity Center sessions for humans;
they solve different trust boundaries and should be used together.
