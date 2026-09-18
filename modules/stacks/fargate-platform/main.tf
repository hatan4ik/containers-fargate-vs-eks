module "vpc" {
  source = "../../network/vpc"

  name                    = var.name
  cidr                    = var.vpc_cidr
  availability_zones      = var.availability_zones
  single_nat_gateway      = var.single_nat_gateway
  flow_log_group_name     = var.flow_log_group_name
  flow_log_role_name      = var.flow_log_role_name
  flow_log_retention_days = var.flow_log_retention_days
  flow_log_kms_key_id     = var.flow_log_kms_key_id
  tags                    = local.tags
}

module "application_logs" {
  source = "../../observability/log-group"

  name           = "/${var.name}/apps"
  retention_days = var.application_log_retention_days
  kms_key_id     = var.application_log_kms_key_id
  tags           = local.tags
}

module "cluster" {
  source = "../../compute/ecs-cluster"

  name                       = var.name
  vpc_id                     = module.vpc.vpc_id
  vpc_cidr                   = var.vpc_cidr
  public_subnet_ids          = module.vpc.public_subnet_id_list
  certificate_arn            = var.certificate_arn
  alb_ingress_cidrs          = var.alb_ingress_cidrs
  allow_public_ingress       = var.allow_public_ingress
  alb_access_logs            = var.alb_access_logs
  enable_deletion_protection = var.enable_deletion_protection
  tags                       = local.tags
}

module "gateway" {
  source = "../../compute/ecs-service"

  name                           = var.name
  service_name                   = "gateway"
  region                         = var.region
  cluster_id                     = module.cluster.cluster_id
  cluster_name                   = module.cluster.cluster_name
  vpc_id                         = module.vpc.vpc_id
  vpc_cidr                       = var.vpc_cidr
  private_subnet_ids             = module.vpc.private_subnet_id_list
  image                          = var.services.gateway.image
  port                           = 3000
  desired_count                  = var.services.gateway.desired_count
  log_group_name                 = module.application_logs.name
  task_execution_role_arn        = module.cluster.task_execution_role_arn
  task_role_arn                  = module.cluster.task_role_arn
  ingress_security_group_id      = module.cluster.alb_sg_id
  https_egress_cidrs             = var.https_egress_cidrs
  allow_public_https_egress      = var.allow_public_https_egress
  service_discovery_namespace_id = module.cluster.service_discovery_namespace_id
  enable_service_discovery       = true
  load_balancer = {
    target_group_arn = module.cluster.gateway_target_group_arn
    container_port   = 3000
  }
  egress_rules = concat([
    {
      description = "orders-service"
      from_port   = 3002
      to_port     = 3002
      ip_protocol = "tcp"
      cidr_ipv4   = var.vpc_cidr
    },
  ], var.services.gateway.extra_egress_rules)
  autoscaling = var.services.gateway.autoscaling
  tags        = local.tags
}

module "orders" {
  source = "../../compute/ecs-service"

  name                           = var.name
  service_name                   = "orders"
  region                         = var.region
  cluster_id                     = module.cluster.cluster_id
  cluster_name                   = module.cluster.cluster_name
  vpc_id                         = module.vpc.vpc_id
  vpc_cidr                       = var.vpc_cidr
  private_subnet_ids             = module.vpc.private_subnet_id_list
  image                          = var.services.orders.image
  port                           = 3002
  desired_count                  = var.services.orders.desired_count
  environment                    = [{ name = "USERS_BASE_URL", value = "http://users.${var.name}.local:3001" }]
  log_group_name                 = module.application_logs.name
  task_execution_role_arn        = module.cluster.task_execution_role_arn
  task_role_arn                  = module.cluster.task_role_arn
  ingress_security_group_id      = module.gateway.security_group_id
  https_egress_cidrs             = var.https_egress_cidrs
  allow_public_https_egress      = var.allow_public_https_egress
  service_discovery_namespace_id = module.cluster.service_discovery_namespace_id
  enable_service_discovery       = true
  egress_rules = concat([
    {
      description = "users-service"
      from_port   = 3001
      to_port     = 3001
      ip_protocol = "tcp"
      cidr_ipv4   = var.vpc_cidr
    },
  ], var.services.orders.extra_egress_rules)
  autoscaling = var.services.orders.autoscaling
  tags        = local.tags
}

module "users" {
  source = "../../compute/ecs-service"

  name                           = var.name
  service_name                   = "users"
  region                         = var.region
  cluster_id                     = module.cluster.cluster_id
  cluster_name                   = module.cluster.cluster_name
  vpc_id                         = module.vpc.vpc_id
  vpc_cidr                       = var.vpc_cidr
  private_subnet_ids             = module.vpc.private_subnet_id_list
  image                          = var.services.users.image
  port                           = 3001
  desired_count                  = var.services.users.desired_count
  log_group_name                 = module.application_logs.name
  task_execution_role_arn        = module.cluster.task_execution_role_arn
  task_role_arn                  = module.cluster.task_role_arn
  ingress_security_group_id      = module.orders.security_group_id
  https_egress_cidrs             = var.https_egress_cidrs
  allow_public_https_egress      = var.allow_public_https_egress
  service_discovery_namespace_id = module.cluster.service_discovery_namespace_id
  enable_service_discovery       = true
  egress_rules                   = var.services.users.extra_egress_rules
  autoscaling                    = var.services.users.autoscaling
  tags                           = local.tags
}
