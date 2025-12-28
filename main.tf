module "vpc" {
source  = "terraform-aws-modules/vpc/aws"
version = "~> 5.0"
name = "${var.cluster_name}-vpc"
cidr = var.vpc_cidr
azs             = ["ap-south-1a", "ap-south-1b"]
private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
enable_nat_gateway   = true
single_nat_gateway   = true
enable_dns_hostnames = true
tags = var.tags
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_irsa = true

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = false

  cluster_enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  cluster_encryption_config = {
    resources = ["secrets"]
  }

  eks_managed_node_groups = {

    on_demand = {
      name            = "on-demand-ng"
      instance_types  = ["t3.medium"]
      capacity_type   = "ON_DEMAND"
      min_size        = 2
      max_size        = 5
      desired_size    = 2
    }

    spot = {
      name            = "spot-ng"
      instance_types  = ["t3.medium", "t3a.medium"]
      capacity_type   = "SPOT"
      min_size        = 1
      max_size        = 4
      desired_size    = 1
    }
  }

  tags = var.tags
}
