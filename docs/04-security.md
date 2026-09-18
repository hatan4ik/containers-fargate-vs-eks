# Security model

## Identity and CI/CD

GitHub Actions is the active CI authority. Its protected Environment supplies
non-secret backend/role variables and the `TERRAFORM_TFVARS_B64` secret; the
workflow receives short-lived AWS credentials through GitHub OIDC. It never uses
AWS access keys and it contains no Terraform apply step.

The required per-Environment variables are `AWS_REGION`, `TF_STATE_BUCKET`,
`TF_STATE_KMS_KEY_ID`, `TF_STATE_REGION`, and `TERRAFORM_PLAN_ROLE_ARN`. The
`fargate-*` Environments additionally own `ECR_REGISTRY` and
`ECR_PUBLISH_ROLE_ARN`. ECR publishing is separately trusted, limited to the
three pre-created repositories, and limited to a protected environment and
`service-v*` release tags (or a reviewed manual dispatch).

`.gitlab-ci.yml` and `azure-pipelines.yml` are optional manual-by-default OIDC
templates for intentionally separate CI authorities. Their providers and roles
are created through `bootstrap/external-ci-oidc`, whose trust policies require
the provider audience and exact CI subject. Do not configure two CI authorities
to manage the same AWS environment.

Human operators authenticate through MFA-backed IAM Identity Center sessions.
OIDC protects workload automation and MFA protects interactive humans; neither is
a substitute for the other. The end-to-end setup is in
[AWS_SETUP.md](AWS_SETUP.md).

## State and secret handling

Terraform state uses an encrypted, versioned S3 bucket with public-access
blocking, TLS-only access, native S3 lockfiles, lifecycle cleanup, and
cross-region replication. It has a dedicated KMS key and separately provisioned
access-log and disaster-recovery destinations. Real `terraform.tfvars`, backend
configuration, plan files, and bootstrap output stay ignored and outside Git.

The CI planner decodes its short-lived configuration only in the job workspace,
generates a JSON plan for a non-sensitive action-count summary, and removes both
the configuration and plan artifacts on exit. It never uploads a binary plan or
prints input values.

## Runtime security

- ECS tasks run in private subnets. Security groups permit only ALB → gateway →
  orders → users; task egress is limited to dependencies, DNS, and HTTPS for AWS
  control-plane services.
- The EKS control-plane endpoint is private. Workloads run non-root with a
  read-only filesystem, dropped Linux capabilities, resource limits, and
  NetworkPolicies enforced by the EKS VPC CNI.
- ECS Exec is enabled for incident response. Its task role has only required
  `ssmmessages` permissions; operator IAM access remains an account-level
  prerequisite.
- Workload CloudWatch log encryption and EKS envelope encryption use separate
  customer-managed KMS keys; neither reuses the state KMS key.

The state bootstrap requires a dedicated S3 access-log destination, a versioned
cross-region replica bucket and replica KMS key, and its account-root principal
ARN. It enables EventBridge notifications for state-bucket audit events. The only
Checkov waivers are KMS-policy checks that require `Resource: "*"` by AWS design;
their principals are explicitly constrained in the key policy. Review the waiver
by 2027-09-18 and remove it when the scanner can model this AWS KMS requirement
without a wildcard-resource finding.
