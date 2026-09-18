resource "aws_iam_openid_connect_provider" "github" {
  count = var.github_oidc_provider_arn == null ? 1 : 0

  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  tags           = local.tags
}

data "aws_iam_policy_document" "github_assume" {
  for_each = var.environments

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repository}:environment:${each.value.github_environment}"]
    }
  }
}

resource "aws_iam_role" "plan" {
  for_each = var.environments

  name               = "${var.name}-${each.key}-terraform-plan"
  assume_role_policy = data.aws_iam_policy_document.github_assume[each.key].json
  tags               = merge(local.tags, { Environment = each.key, Access = "plan" })
}

resource "aws_iam_role" "apply" {
  for_each = var.environments

  name               = "${var.name}-${each.key}-terraform-apply"
  assume_role_policy = data.aws_iam_policy_document.github_assume[each.key].json
  tags               = merge(local.tags, { Environment = each.key, Access = "apply" })
}

data "aws_iam_policy_document" "plan_state" {
  for_each = var.environments

  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [var.state_bucket_arn]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = [each.value.state_key, "${each.value.state_key}.tflock"]
    }
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${var.state_bucket_arn}/${each.value.state_key}"]
  }

  statement {
    effect  = "Allow"
    actions = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = [
      "${var.state_bucket_arn}/${each.value.state_key}.tflock",
    ]
  }

  statement {
    effect    = "Allow"
    actions   = ["kms:Decrypt", "kms:DescribeKey", "kms:Encrypt", "kms:GenerateDataKey"]
    resources = [var.kms_key_arn]
  }
}

data "aws_iam_policy_document" "apply_state" {
  for_each = var.environments

  source_policy_documents = [data.aws_iam_policy_document.plan_state[each.key].json]

  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${var.state_bucket_arn}/${each.value.state_key}"]
  }
}

resource "aws_iam_role_policy" "plan_state" {
  for_each = var.environments

  name   = "${var.name}-${each.key}-terraform-plan-state"
  role   = aws_iam_role.plan[each.key].id
  policy = data.aws_iam_policy_document.plan_state[each.key].json
}

resource "aws_iam_role_policy" "apply_state" {
  for_each = var.environments

  name   = "${var.name}-${each.key}-terraform-apply-state"
  role   = aws_iam_role.apply[each.key].id
  policy = data.aws_iam_policy_document.apply_state[each.key].json
}

resource "aws_iam_role_policy_attachment" "plan_read_only" {
  for_each = var.environments

  role       = aws_iam_role.plan[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "apply_workload" {
  for_each = local.apply_policy_attachments

  role       = aws_iam_role.apply[each.value.environment_name].name
  policy_arn = each.value.policy_arn
}
