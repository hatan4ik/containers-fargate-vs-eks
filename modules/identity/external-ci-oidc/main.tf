resource "aws_iam_openid_connect_provider" "this" {
  url             = var.issuer_url
  client_id_list  = [var.audience]
  thumbprint_list = var.thumbprint_list
  tags            = local.tags
}

data "aws_iam_policy_document" "assume" {
  for_each = var.roles

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.this.arn]
    }

    dynamic "condition" {
      for_each = local.role_conditions[each.key]

      content {
        test     = "StringEquals"
        variable = condition.key
        values   = condition.value
      }
    }
  }
}

resource "aws_iam_role" "this" {
  for_each = var.roles

  name               = "${var.name}-${each.key}"
  assume_role_policy = data.aws_iam_policy_document.assume[each.key].json
  tags               = merge(local.tags, { Access = "ci", Role = each.key })
}

resource "aws_iam_role_policy_attachment" "workload" {
  for_each = local.policy_attachments

  role       = aws_iam_role.this[each.value.role_key].name
  policy_arn = each.value.policy_arn
}
