terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = ">= 5.0" }
  }
}

resource "aws_cloudwatch_log_group" "apps" {
  name              = "/${var.name}/apps"
  retention_in_days = 14
  tags = { Name = "${var.name}-apps-logs" }
}
