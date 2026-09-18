resource "aws_vpc" "this" {
  cidr_block           = var.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(local.tags, { Name = "${var.name}-vpc" })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags   = merge(local.tags, { Name = "${var.name}-igw" })
}

# ── Subnets (for_each on AZ name — stable keys) ──────────────────────────────

resource "aws_subnet" "public" {
  for_each          = local.az_keys
  vpc_id            = aws_vpc.this.id
  cidr_block        = local.az_public_cidrs[each.key]
  availability_zone = each.key
  # Public routing is for load balancers and NAT gateways. Workloads must
  # explicitly request an address; this module never assigns public IPv4s.
  map_public_ip_on_launch = false
  tags = merge(local.tags, {
    Name = "${var.name}-public-${each.key}"
  }, local.public_subnet_tags)
}

resource "aws_subnet" "private" {
  for_each          = local.az_keys
  vpc_id            = aws_vpc.this.id
  cidr_block        = local.az_private_cidrs[each.key]
  availability_zone = each.key
  tags = merge(local.tags, {
    Name = "${var.name}-private-${each.key}"
  }, local.private_subnet_tags)
}

# ── NAT Gateways ─────────────────────────────────────────────────────────────

resource "aws_eip" "nat" {
  for_each = local.nat_keys
  domain   = "vpc"
  tags     = merge(local.tags, { Name = "${var.name}-nat-eip-${each.key}" })
}

resource "aws_nat_gateway" "nat" {
  for_each      = local.nat_keys
  allocation_id = aws_eip.nat[each.key].id
  # Single NAT → first AZ subnet; per-AZ NAT → matching AZ subnet.
  subnet_id  = var.single_nat_gateway ? aws_subnet.public[var.availability_zones[0]].id : aws_subnet.public[each.key].id
  depends_on = [aws_internet_gateway.igw]
  tags       = merge(local.tags, { Name = "${var.name}-nat-${each.key}" })
}

# ── Route tables ─────────────────────────────────────────────────────────────

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags   = merge(local.tags, { Name = "${var.name}-rt-public" })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
  for_each       = local.az_keys
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  for_each = local.az_keys
  vpc_id   = aws_vpc.this.id
  tags     = merge(local.tags, { Name = "${var.name}-rt-private-${each.key}" })
}

resource "aws_route" "private_nat" {
  for_each               = local.az_keys
  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.single_nat_gateway ? aws_nat_gateway.nat["0"].id : aws_nat_gateway.nat[each.key].id
}

resource "aws_route_table_association" "private" {
  for_each       = local.az_keys
  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}

# ── VPC Flow Logs ─────────────────────────────────────────────────────────────

resource "aws_cloudwatch_log_group" "vpc_flow" {
  name              = local.flow_log_group_name
  retention_in_days = var.flow_log_retention_days
  kms_key_id        = var.flow_log_kms_key_id
  tags              = merge(local.tags, { Name = "${var.name}-vpc-flow-logs" })
}

data "aws_iam_policy_document" "flow_logs_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "flow_logs" {
  statement {
    actions   = ["logs:CreateLogStream", "logs:DescribeLogStreams", "logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.vpc_flow.arn}:*"]
  }
}

resource "aws_iam_role" "flow_logs" {
  name               = local.flow_log_role_name
  assume_role_policy = data.aws_iam_policy_document.flow_logs_assume.json
  tags               = local.tags
}

resource "aws_iam_role_policy" "flow_logs" {
  name   = "${local.flow_log_role_name}-policy"
  role   = aws_iam_role.flow_logs.id
  policy = data.aws_iam_policy_document.flow_logs.json
}

resource "aws_flow_log" "vpc" {
  iam_role_arn             = aws_iam_role.flow_logs.arn
  log_destination          = aws_cloudwatch_log_group.vpc_flow.arn
  log_destination_type     = "cloud-watch-logs"
  max_aggregation_interval = 60
  traffic_type             = "ALL"
  vpc_id                   = aws_vpc.this.id
  depends_on               = [aws_iam_role_policy.flow_logs]
}
