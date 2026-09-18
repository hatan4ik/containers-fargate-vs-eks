# Access setup for this repository

This is the access model required to run this repository safely. It uses
short-lived AWS IAM Identity Center credentials for people and OIDC roles for
CI. Terraform, GitHub Actions, GitLab, and Azure DevOps do **not** need an IAM
user access key.

## Choose the right access path

| Activity                                             | Identity to use                                          | What it is allowed to do                                                                                  |
| ---------------------------------------------------- | -------------------------------------------------------- | --------------------------------------------------------------------------------------------------------- |
| Local formatting, tests, and backend-free validation | None                                                     | `npm` and Terraform checks only; it makes no AWS calls.                                                   |
| Read-only local preflight                            | IAM Identity Center profile                              | `sts:GetCallerIdentity` plus local Terraform validation.                                                  |
| One-time state/OIDC bootstrap                        | Time-bound MFA-backed `PlatformBootstrap` permission set | Create only reviewed state, KMS, IAM OIDC, and role resources in the selected account.                    |
| GitHub Terraform plan                                | Environment-scoped GitHub OIDC plan role                 | Read the one state file, acquire its lock, decrypt its state key, and read AWS resources.                 |
| Terraform apply                                      | Separate reviewed apply role/process                     | Only the approved environment policy and its state file. This repository has no automatic apply workflow. |
| ECR release                                          | Separate GitHub OIDC publish role                        | Push immutable images only to `gateway`, `users`, and `orders`.                                           |

Do not use an IAM user, root user, static access key, or credentials pasted into
a terminal/chat for the CI or Terraform workflow. If a key has been shared or
returns `InvalidClientTokenId`, revoke/rotate it rather than trying to repair it.

## 1. Have an AWS administrator establish human access

An administrator must first enable IAM Identity Center in the AWS account or
Organization, create a user/group for you, require MFA in its identity provider,
and assign that group to the target AWS account. Permission sets are the right
place to define this access; AWS provisions their permissions into the selected
account when an assignment is made.

Create two named permission sets:

1. `PlatformReadOnly` for normal investigation and preflight. It needs no write
   privileges.
2. `PlatformBootstrap` for the short, one-time bootstrap window. Give it only
   the reviewed capability to create the resources shown by
   `bootstrap/state-backend`'s plan: its S3 state bucket/KMS key and supporting
   configuration, GitHub OIDC provider, environment plan/apply roles, and the
   IAM policy attachments those roles need. Scope S3 and KMS permissions to the
   approved state and disaster-recovery names wherever the bootstrap plan makes
   that possible. Remove this assignment after bootstrap, or reduce it to a
   read-only/operator permission set.

The administrator assigns the group under **IAM Identity Center → AWS accounts
→ target account → Assign users or groups**, selects the appropriate permission
set, reviews it, and submits. The AWS account-assignment flow and permission-set
semantics are documented by AWS: [assign account access](https://docs.aws.amazon.com/singlesignon/latest/userguide/assignusers.html) and
[create a permission set](https://docs.aws.amazon.com/singlesignon/latest/userguide/howtocreatepermissionset.html).

## 2. Configure your local AWS CLI once

Ask the administrator for these non-secret values:

- IAM Identity Center start URL
- IAM Identity Center region
- target AWS account ID
- `PlatformReadOnly` or `PlatformBootstrap` permission-set name
- workload region (for example, `us-east-1`)

Run the AWS CLI wizard and accept the browser sign-in. It writes an SSO profile
to `~/.aws/config`; it does not store an IAM user secret access key.

```bash
aws configure sso --profile platform-bootstrap
aws sso login --profile platform-bootstrap
aws sts get-caller-identity --profile platform-bootstrap
```

The final command must show the expected account and an assumed-role ARN. If it
does not, stop—do not run Terraform. The AWS CLI's SSO configuration and
short-lived credential flow are described in the [AWS CLI guide](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html).

For the current terminal, point Terraform and the helper scripts at the profile:

```bash
export AWS_PROFILE=platform-bootstrap
export AWS_SDK_LOAD_CONFIG=1
export AWS_REGION=us-east-1
```

`AWS_PROFILE` is inherited by the AWS provider and the S3 backend. Never put
AWS keys into `terraform.tfvars`, GitHub secrets, `.env` files, or source code.

## 3. Prove local access before any state-changing operation

The preflight validates the selected identity, pinned Terraform version, a
completed environment `terraform.tfvars`, and backend-free Terraform syntax.
It cannot create or modify AWS resources.

```bash
AWS_PROFILE=platform-bootstrap \
  scripts/aws-preflight.sh --environment fargate-dev --region us-east-1
```

Expected outcomes:

- `AWS identity verified` confirms the AWS CLI has usable temporary credentials.
- `Validated ... without accessing remote state` confirms the root is syntactically
  ready.
- `AccessDenied` means the permission set is missing a specific action; capture
  the action/resource from CloudTrail or the CLI error and have the administrator
  add that scoped permission. Do not permanently add `AdministratorAccess` to
  solve a single missing action.

## 4. Bootstrap state and GitHub OIDC access

Complete the external dependency checklist in [AWS_SETUP.md](AWS_SETUP.md) first.
With the short-lived `PlatformBootstrap` profile active, copy the example to the
ignored local file, enter approved values, and review the plan:

```bash
cd bootstrap/state-backend
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan -out=bootstrap.tfplan
terraform show bootstrap.tfplan
```

The approved bootstrap creates exact GitHub OIDC trust per environment. Its
plan roles already receive state-keyed lock/read/decrypt access and AWS
`ReadOnlyAccess`; apply roles receive state-write access plus only the
environment-specific customer-managed policy ARNs supplied in
`apply_policy_arns`.

After an approved bootstrap apply, export its non-secret outputs to a protected
location, remove the `PlatformBootstrap` assignment, and configure the protected
GitHub Environment variables with the repository script:

```bash
terraform output -json > /safe/path/bootstrap-outputs.json
cd ../..
scripts/configure-github-environments.sh \
  --bootstrap-outputs /safe/path/bootstrap-outputs.json \
  --aws-region us-east-1 --state-region us-east-1 \
  --repo hatan4ik/containers-fargate-vs-eks
```

The command above is dry-run. Follow the script's `--apply` instruction only
after GitHub Environment reviewers and deployment-branch restrictions are set.
That script requires a GitHub CLI session with administrative access to this
repository's Environment variables:

```bash
gh auth login --hostname github.com --web
gh auth status
```

## 5. CI requires no human AWS profile

GitHub Actions exchanges its job OIDC token for the plan or ECR-publish role.
Configure the resulting role ARNs as protected Environment variables and set
the reviewed root input as `TERRAFORM_TFVARS_B64` Environment secret, as shown
in [AWS_SETUP.md](AWS_SETUP.md). CI should never receive your SSO session, IAM
user key, or `PlatformBootstrap` permission set.

The repository ships optional manual GitLab and Azure DevOps pipeline templates.
If you adopt one, create its **own** exact-subject OIDC role using
`bootstrap/external-ci-oidc`; do not reuse a GitHub role or let two CI systems
manage the same target environment.

## 6. Recovery and cleanup

- SSO expired: run `aws sso login --profile platform-bootstrap` again.
- Wrong account: check `aws sts get-caller-identity --profile platform-bootstrap`
  before running any Terraform command.
- Lost MFA device: use an administrator to replace the MFA device, then keep MFA
  required. AWS documents MFA-device deactivation as a recovery step, not a
  permanent CI access mechanism: [AWS MFA recovery](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_mfa_disable.html).
- Exposed IAM key: deactivate/delete it in IAM and audit CloudTrail. Migrate the
  workflow to the SSO/OIDC model above; AWS recommends temporary credentials for
  human and workload access. [AWS IAM best practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)

Once steps 1–5 are complete, a maintainer can safely run the manual GitHub
Terraform plan. Terraform apply remains a deliberately separate, approved
operation.
