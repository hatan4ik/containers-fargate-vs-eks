# External CI OIDC bootstrap

Creates a distinct IAM OIDC provider and exact-subject role set for GitLab or
Azure DevOps. Run it only after `bootstrap/state-backend` has created protected
remote state. It never creates static IAM users or access keys.

1. Copy `terraform.tfvars.example` to ignored `terraform.tfvars` and replace all
   identity-provider, role-policy, and thumbprint placeholders.
2. Copy `backend.hcl.example` outside the repository and initialize the secure
   state backend.
3. Run `terraform plan` using a human MFA/SSO session. Apply only after the AWS
   trust policy subject exactly matches the CI service connection/project.

`providers` is map-driven: adding another CI role is one new stable entry in
`terraform.tfvars`, not a copied IAM resource block.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
