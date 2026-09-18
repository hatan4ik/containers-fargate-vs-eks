module "platform" {
  source = "git::https://github.com/hatan4ik/containers-fargate-vs-eks.git//modules/stacks/fargate-platform?ref=modules-v1.1.0"

  name                      = local.name_prefix
  region                    = var.region
  vpc_cidr                  = var.vpc_cidr
  availability_zones        = var.availability_zones
  single_nat_gateway        = var.single_nat_gateway
  certificate_arn           = var.certificate_arn
  allow_insecure_http       = var.allow_insecure_http
  alb_ingress_cidrs         = var.alb_ingress_cidrs
  allow_public_ingress      = var.allow_public_ingress
  https_egress_cidrs        = var.https_egress_cidrs
  allow_public_https_egress = var.allow_public_https_egress
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
