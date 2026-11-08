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
