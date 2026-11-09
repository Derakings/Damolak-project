locals {
  name         = "${var.project}-${var.environment}"
  cluster_name = "${local.name}-eks"
}

module "network" {
  source       = "../../modules/network"
  name         = local.name
  cluster_name = local.cluster_name
}

module "ecr" {
  source = "../../modules/ecr"
  name   = "${local.name}-app"
}

module "eks" {
  source             = "../../modules/eks"
  cluster_name       = local.cluster_name
  kubernetes_version = var.kubernetes_version
  subnet_ids         = module.network.private_subnet_ids
  node_instance_type = var.node_instance_type
  node_desired_size  = var.node_desired_size
}

module "monitoring" {
  source       = "../../modules/monitoring"
  cluster_name = module.eks.cluster_name
  alert_email  = var.alert_email
  depends_on   = [module.eks] # the add-on needs the worker nodes to exist first
}

module "jenkins" {
  source                    = "../../modules/jenkins"
  name                      = local.name
  vpc_id                    = module.network.vpc_id
  subnet_id                 = module.network.public_subnet_ids[0]
  cluster_name              = module.eks.cluster_name
  cluster_security_group_id = module.eks.cluster_security_group_id
  allowed_cidr              = var.jenkins_allowed_cidr
}