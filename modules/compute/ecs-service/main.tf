# ── Security Group ────────────────────────────────────────────────────────────

resource "aws_security_group" "this" {
  name        = "${local.full_name}-sg"
  description = "${var.service_name} task security group"
  vpc_id      = var.vpc_id
  tags        = merge(local.tags, { Name = "${local.full_name}-sg" })

  lifecycle {
    precondition {
      condition     = var.allow_public_https_egress || !contains(tolist(var.https_egress_cidrs), "0.0.0.0/0")
      error_message = "0.0.0.0/0 HTTPS egress requires allow_public_https_egress = true."
    }
  }
}

resource "aws_vpc_security_group_ingress_rule" "service_port" {
  security_group_id            = aws_security_group.this.id
  description                  = "Ingress from upstream on service port"
  from_port                    = var.port
  to_port                      = var.port
  ip_protocol                  = "tcp"
  referenced_security_group_id = var.ingress_security_group_id
}

# Standard egress: HTTPS (ECR, CloudWatch, SSM) + DNS (UDP+TCP)
resource "aws_vpc_security_group_egress_rule" "https" {
  for_each = var.https_egress_cidrs

  security_group_id = aws_security_group.this.id
  description       = "HTTPS egress to ${each.value}"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = each.value
}

resource "aws_vpc_security_group_egress_rule" "dns_udp" {
  security_group_id = aws_security_group.this.id
  description       = "DNS UDP"
  from_port         = 53
  to_port           = 53
  ip_protocol       = "udp"
  cidr_ipv4         = var.vpc_cidr
}

resource "aws_vpc_security_group_egress_rule" "dns_tcp" {
  security_group_id = aws_security_group.this.id
  description       = "DNS TCP"
  from_port         = 53
  to_port           = 53
  ip_protocol       = "tcp"
  cidr_ipv4         = var.vpc_cidr
}

# Caller-supplied egress rules (e.g. gateway→orders on 3002, orders→users on 3001)
resource "aws_vpc_security_group_egress_rule" "extra" {
  for_each = { for r in var.egress_rules : r.description => r }

  security_group_id            = aws_security_group.this.id
  description                  = each.value.description
  from_port                    = each.value.from_port
  to_port                      = each.value.to_port
  ip_protocol                  = each.value.ip_protocol
  cidr_ipv4                    = each.value.cidr_ipv4
  referenced_security_group_id = each.value.referenced_sg_id
}

# ── Task Definition ───────────────────────────────────────────────────────────

resource "aws_ecs_task_definition" "this" {
  family                   = local.full_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = tostring(var.cpu)
  memory                   = tostring(var.memory)
  execution_role_arn       = var.task_execution_role_arn
  task_role_arn            = var.task_role_arn
  tags                     = local.tags

  lifecycle {
    precondition {
      condition = contains([
        "256/512", "256/1024", "256/2048",
        "512/1024", "512/2048", "512/3072", "512/4096",
        "1024/2048", "1024/3072", "1024/4096", "1024/5120", "1024/6144", "1024/7168", "1024/8192",
        "2048/4096", "2048/5120", "2048/6144", "2048/7168", "2048/8192", "2048/9216", "2048/10240", "2048/11264", "2048/12288", "2048/13312", "2048/14336", "2048/15360", "2048/16384",
        "4096/8192", "4096/9216", "4096/10240", "4096/11264", "4096/12288", "4096/13312", "4096/14336", "4096/15360", "4096/16384", "4096/17408", "4096/18432", "4096/19456", "4096/20480", "4096/21504", "4096/22528", "4096/23552", "4096/24576", "4096/25600", "4096/26624", "4096/27648", "4096/28672", "4096/29696", "4096/30720",
      ], "${var.cpu}/${var.memory}")
      error_message = "memory is not valid for the selected Fargate cpu value."
    }
  }

  container_definitions = jsonencode([{
    name                   = var.service_name
    image                  = var.image
    essential              = true
    user                   = "1000"
    readonlyRootFilesystem = true
    linuxParameters        = { initProcessEnabled = true }
    stopTimeout            = 30
    portMappings           = [{ containerPort = var.port, protocol = "tcp" }]
    environment            = local.container_environment
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = var.log_group_name
        "awslogs-region"        = var.region
        "awslogs-stream-prefix" = var.service_name
      }
    }
    healthCheck = {
      command     = ["CMD-SHELL", "wget -q -O - http://localhost:${var.port}/healthz || exit 1"]
      interval    = 30
      timeout     = 5
      retries     = 3
      startPeriod = 10
    }
  }])
}

# ── Service Discovery ─────────────────────────────────────────────────────────

resource "aws_service_discovery_service" "this" {
  count = var.service_discovery_namespace_id != null ? 1 : 0
  name  = var.service_name
  tags  = local.tags

  dns_config {
    namespace_id = var.service_discovery_namespace_id
    dns_records {
      ttl  = 10
      type = "A"
    }
  }

  health_check_custom_config {}
}

# ── ECS Service ───────────────────────────────────────────────────────────────

resource "aws_ecs_service" "this" {
  name                              = local.full_name
  cluster                           = var.cluster_id
  task_definition                   = aws_ecs_task_definition.this.arn
  desired_count                     = var.desired_count
  launch_type                       = "FARGATE"
  enable_execute_command            = true
  health_check_grace_period_seconds = var.health_check_grace_period_seconds
  propagate_tags                    = "SERVICE"
  tags                              = local.tags

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.this.id]
    assign_public_ip = false
  }

  dynamic "service_registries" {
    for_each = var.service_discovery_namespace_id != null ? [1] : []
    content {
      registry_arn = aws_service_discovery_service.this[0].arn
    }
  }

  dynamic "load_balancer" {
    for_each = var.load_balancer != null ? [var.load_balancer] : []
    content {
      target_group_arn = load_balancer.value.target_group_arn
      container_name   = var.service_name
      container_port   = load_balancer.value.container_port
    }
  }

  lifecycle {
    precondition {
      condition     = var.load_balancer == null || try(var.load_balancer.container_port == var.port, false)
      error_message = "load_balancer.container_port must equal port."
    }
  }
}

# ── Autoscaling ───────────────────────────────────────────────────────────────

resource "aws_appautoscaling_target" "this" {
  count              = var.autoscaling != null ? 1 : 0
  max_capacity       = var.autoscaling.max_capacity
  min_capacity       = var.autoscaling.min_capacity
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "cpu" {
  count              = var.autoscaling != null ? 1 : 0
  name               = "${local.full_name}-cpu"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this[0].resource_id
  scalable_dimension = aws_appautoscaling_target.this[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.this[0].service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = var.autoscaling.cpu_target
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = var.autoscaling.scale_in_cooldown
    scale_out_cooldown = var.autoscaling.scale_out_cooldown
  }
}
