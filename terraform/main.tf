# EKS GitOps Platform - Main Terraform Configuration

terraform {
  required_version = ">= 1.6"

  # Uncomment for S3 backend (configure after initial setup)
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "eks-gitops-platform/terraform.tfstate"
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "terraform-state-lock"
  # }
}

# VPC Module - Network infrastructure
module "vpc" {
  source = "./modules/vpc"

  cluster_name       = var.cluster_name
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  tags               = var.tags
}

# IAM Module - Roles and policies for EKS and IRSA
# Note: This creates a circular dependency that Terraform can handle
# The cluster and node roles are created first, then EKS cluster,
# then OIDC provider and IRSA roles are created using the cluster's OIDC issuer
module "iam" {
  source = "./modules/iam"

  cluster_name                 = var.cluster_name
  cluster_oidc_issuer_url      = module.eks.cluster_oidc_issuer_url
  enable_cert_manager_route53  = false  # Using HTTP-01 challenge, not DNS-01
  tags                         = var.tags
}

# EKS Module - Kubernetes cluster
module "eks" {
  source = "./modules/eks"

  cluster_name               = var.cluster_name
  cluster_version            = var.cluster_version
  private_subnet_ids         = module.vpc.private_subnet_ids
  public_subnet_ids          = module.vpc.public_subnet_ids
  cluster_role_arn           = module.iam.cluster_role_arn
  node_group_role_arn        = module.iam.node_group_role_arn
  node_group_desired_size    = var.node_group_desired_size
  node_group_min_size        = var.node_group_min_size
  node_group_max_size        = var.node_group_max_size
  node_instance_types        = var.node_instance_types
  tags                       = var.tags
}

# Route53 Module - DNS hosted zone
module "route53" {
  source = "./modules/route53"

  cluster_name = var.cluster_name
  domain_name  = var.domain_name
  tags         = var.tags
}
