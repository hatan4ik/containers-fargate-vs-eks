terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = ">= 5.0" }
  }
}

resource "aws_cloudwatch_log_group" "eks" {
  name              = "/${var.name}/eks"
  retention_in_days = 14
}
