output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC."
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "Map of AZ name → public subnet ID."
  value       = { for az, s in aws_subnet.public : az => s.id }
}

output "private_subnet_ids" {
  description = "Map of AZ name → private subnet ID."
  value       = { for az, s in aws_subnet.private : az => s.id }
}

output "public_subnet_id_list" {
  description = "Ordered list of public subnet IDs (sorted by AZ name)."
  value       = [for az in sort(keys(aws_subnet.public)) : aws_subnet.public[az].id]
}

output "private_subnet_id_list" {
  description = "Ordered list of private subnet IDs (sorted by AZ name)."
  value       = [for az in sort(keys(aws_subnet.private)) : aws_subnet.private[az].id]
}

output "flow_log_group_name" {
  description = "Name of the VPC flow log CloudWatch log group."
  value       = aws_cloudwatch_log_group.vpc_flow.name
}

output "flow_log_role_name" {
  description = "Name of the IAM role used by VPC flow logs."
  value       = aws_iam_role.flow_logs.name
}
