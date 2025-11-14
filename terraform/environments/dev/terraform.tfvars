# Development Environment Configuration

# Cluster Configuration
cluster_name    = "eks-gitops-platform-dev"
cluster_version = "1.28"
region          = "us-east-2"

# Domain Configuration
domain_name = "nouha-zouaghi.cc"

# VPC Configuration
vpc_cidr           = "10.0.0.0/16"
availability_zones = ["us-east-2a", "us-east-2b", "us-east-2c"]

# Node Group Configuration
node_group_desired_size = 2
node_group_min_size     = 1
node_group_max_size     = 4
node_instance_types     = ["t3.medium"]

# Tags
tags = {
  Project     = "eks-gitops-platform"
  Environment = "dev"
  ManagedBy   = "terraform"
  Owner       = "platform-team"
}
