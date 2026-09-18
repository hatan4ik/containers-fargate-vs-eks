module "platform" {
  # Release tag modules-v1.3.0 resolves to this immutable commit.
  source = "git::https://github.com/hatan4ik/containers-fargate-vs-eks.git//modules/stacks/fargate-platform?ref=280f2e70959cdb2450ff71dcbc4dd4fabd2c7d5d"

  name                       = local.name_prefix
  region                     = var.region
  vpc_cidr                   = var.vpc_cidr
  availability_zones         = var.availability_zones
  single_nat_gateway         = var.single_nat_gateway
  certificate_arn            = var.certificate_arn
  alb_ingress_cidrs          = var.alb_ingress_cidrs
  allow_public_ingress       = var.allow_public_ingress
  flow_log_kms_key_id        = var.flow_log_kms_key_id
  application_log_kms_key_id = var.application_log_kms_key_id
  alb_access_logs            = var.alb_access_logs
  waf_log_destination_arn    = var.waf_log_destination_arn
  https_egress_cidrs         = var.https_egress_cidrs
  allow_public_https_egress  = var.allow_public_https_egress
  services = {
    gateway = {
      image         = var.service_images.gateway
      desired_count = var.service_desired_counts.gateway
      autoscaling   = var.gateway_autoscaling
    }
    orders = {
      image         = var.service_images.orders
      desired_count = var.service_desired_counts.orders
    }
    users = {
      image         = var.service_images.users
      desired_count = var.service_desired_counts.users
    }
  }
  tags = local.tags
}
