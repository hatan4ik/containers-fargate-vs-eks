# Rollback (ECS Fargate)

Options:

- Re-deploy previous image tag
- Reduce desired count and re-enable stable target group (if using blue/green later)

For this course baseline: redeploy the prior immutable `sha-<commit-sha>` tag by
updating the Terraform variables and applying. Do not reuse the mutable `main` tag.
